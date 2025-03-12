{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.personal.nix;
  hasFlake = cfg.flake != null;
  hasFlakeInputs = cfg.autoUpgrade.autoUpdateInputs != [];
  checkNetwork = {
    path = [pkgs.unixtools.ping];
    # Check network connectivity
    preStart = "(${lib.concatMapStringsSep " && " (host: "ping -c 1 ${host}") cfg.autoUpgrade.checkHosts}) || kill -s SIGUSR1 $$";
    unitConfig = {
      StartLimitIntervalSec = 300;
      StartLimitBurst = 5;
    };
    serviceConfig = {
      Restart = "on-abort";
      RestartSec = 30;
    };
  };
in {
  options.personal.nix = {
    enable = lib.mkEnableOption "nix configuration";
    autoUpgrade = {
      enable = lib.mkEnableOption "automatic system and nixpkgs upgrade";
      autoUpdateInputs = lib.mkOption {
        type = with lib.types; listOf str;
        default = ["nixpkgs" "my-nixpkgs/nur" "nixos-hardware"];
      };
      checkHosts = lib.mkOption {
        type = with lib.types; listOf str;
        default = with builtins; concatMap (match "https://([^/]*)/?") config.nix.settings.substituters;
      };
    };
    flake = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
    };
    gc.enable = lib.mkEnableOption "garbage collection";
    remoteBuilds = {
      enable = lib.mkEnableOption "remote builds";
      machines.hephaistos = {
        enable = lib.mkEnableOption "hephaistos remote builder";
        domain = lib.mkOption {
          type = lib.types.str;
        };
        protocol = lib.mkOption {
          type = lib.types.str;
          # Nix custom ssh-variant that avoids lots of "trusted-users" settings pain
          default = "ssh-ng";
        };
        speedFactor = lib.mkOption {
          type =
            lib.types.int;
          default = 4;
        };
        require = lib.mkOption {
          type =
            lib.types.bool;
          default = true;
          description = ''
            Whether this remote builder is required to build the configuration.
            If so, network connectivity to this remote builder will be checked prior to building.
          '';
        };
      };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      nixpkgs = {
        config.allowUnfree = true;
        flake = lib.mkDefault {
          setNixPath = false;
          setFlakeRegistry = false;
        };
      };
      nix = {
        package = pkgs.lix;
        settings = {
          auto-optimise-store = true;
          experimental-features = ["nix-command" "flakes" "recursive-nix"];
          substituters = ["https://devenv.cachix.org/" "https://nix-community.cachix.org/"];
          trusted-public-keys = ["devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=" "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="];
        };
        extraOptions = ''
          !include secrets.conf
        '';
      };
    }

    (lib.mkIf cfg.gc.enable {
      nix.gc = {
        automatic = true;
        dates = "daily";
        options = "--delete-old";
      };
      systemd.services = {
        nix-gc = {
          after = ["nixos-upgrade.service"];
          personal.monitor = true;
        };
        nix-gc-remove-dead-roots = {
          enable = cfg.gc.enable;
          description = "Remove dead symlinks in /nix/var/nix/gcroots";
          serviceConfig.Type = "oneshot";
          script = "find /nix/var/nix/gcroots -xtype l -delete";
          before = ["nix-gc.service"];
          wantedBy = ["nix-gc.service"];
          personal.monitor = true;
        };
        nix-gc-remove-old-hm-gens = let
          user = config.personal.user;
        in {
          enable = user.enable && user.homeManager.enable;
          description = "Remove old Home Manager generations for user ${user.name}";
          serviceConfig.Type = "oneshot";
          script = "${pkgs.nix}/bin/nix-env --profile /home/${user.name}/.local/state/nix/profiles/home-manager --delete-generations old";
          before = ["nix-gc.service"];
          wantedBy = ["nix-gc.service"];
          personal.monitor = true;
        };
      };
    })

    (lib.mkIf cfg.autoUpgrade.enable {
      personal.boot.unattendedReboot = lib.mkIf config.system.autoUpgrade.allowReboot true;
      system.autoUpgrade = {
        enable = true;
        flags = lib.optional (!hasFlake) "--upgrade-all";
      };
      systemd.services.nixos-upgrade = lib.mkMerge [
        checkNetwork
        {
          preStart = lib.mkAfter ''
            ${config.system.build.nixos-rebuild}/bin/nixos-rebuild dry-build ${toString config.system.autoUpgrade.flags}
          '';
          personal.monitor = true;
        }
        (let
          luksCfg = config.boot.initrd.luks.devices;
          cryptExists = luksCfg ? crypt;
          cryptCfg = luksCfg.crypt;
        in
          lib.mkIf (cryptExists && config.system.autoUpgrade.allowReboot) {
            script = lib.mkAfter ''
              cryptsetup --verbose luksAddKey --key-file /etc/luks/keys/master ${cryptCfg.device} /etc/luks/keys/tmp
            '';
            postStop = ''
              # if a reboot due to nixos-upgrade happens, it should occur within a minute
              sleep 120
              # if no reboot has happened, disable any leftover keyfile
              while cryptsetup --verbose luksRemoveKey ${cryptCfg.device} --key-file /etc/luks/keys/tmp
              do
                :
              done
            '';
          })
      ];
    })

    (lib.mkIf hasFlake {
      # don't use system.autoUpgrade.flake, as it enables the --refresh flag
      assertions = [
        {
          assertion = !((config.system.autoUpgrade.channel != null));
          message = ''
            The options 'system.autoUpgrade.channel' and 'personal.nix.flake' cannot both be set.
          '';
        }
      ];
      system.autoUpgrade.flags = lib.mkForce ["--flake ${cfg.flake}"];
      systemd.services.flake-update = lib.mkIf hasFlakeInputs (lib.mkMerge [
        checkNetwork
        {
          unitConfig.Description = "Update flake inputs";
          serviceConfig = {
            ExecStart = "${config.nix.package}/bin/nix flake update --commit-lock-file --flake ${cfg.flake} " + lib.concatStringsSep " " cfg.autoUpgrade.autoUpdateInputs;
            Type = "oneshot"; # Ensure that it finishes before starting nixos-upgrade
          };
          before = ["nixos-upgrade.service"];
          requiredBy = ["nixos-upgrade.service"];
          path = [pkgs.git];
          personal.monitor = true;
        }
      ]);

      programs.git = lib.mkIf (lib.hasPrefix "git+file" cfg.flake) {
        enable = true;
        config.user = lib.mkDefault {
          name = "Root user of ${config.networking.hostName}";
          email = "root@${config.networking.hostName}";
        };
      };
    })

    (lib.mkIf cfg.remoteBuilds.enable (with cfg.remoteBuilds.machines.hephaistos; {
      nix = {
        distributedBuilds = true;
        settings.builders-use-substitutes = true;
        buildMachines = lib.optional enable {
          inherit protocol speedFactor;
          hostName = "hephaistos.${domain}";
          system = "x86_64-linux";
          maxJobs = 4;
          supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm" "recursive-nix"];
          mandatoryFeatures = [];
        };
      };

      personal.nix.autoUpgrade.checkHosts = lib.mkOptionDefault (lib.optional require "hephaistos.${domain}");

      programs.ssh = {
        extraConfig = lib.optionalString enable ''
          Host hephaistos.${domain}
            # Prevent using ssh-agent or another keyfile, useful for testing
            IdentitiesOnly yes
            IdentityFile /etc/ssh/nixremote
            # The weakly privileged user on the remote builder
            # If not set, 'root' is used – which will hopefully fail
            User nixremote
        '';
        knownHosts."hephaistos.${domain}".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHvtqi8tziBuviUV8LDK2ddQQUbHdJYB02dgWTK5Olxq";
      };
    }))
  ]);
}
