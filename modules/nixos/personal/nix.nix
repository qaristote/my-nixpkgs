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
    preStart = "${pkgs.host}/bin/host 9.9.9.9 || exit 100"; # Check network connectivity
    unitConfig = {
      StartLimitIntervalSec = 300;
      StartLimitBurst = 5;
    };
    serviceConfig = {
      RestartForceExitCode = "100";
      RestartSec = "30";
    };
  };
in {
  options.personal.nix = {
    enable = lib.mkEnableOption "nix configuration";
    autoUpgrade = {
      enable = lib.mkEnableOption "automatic system and nixpkgs upgrade";
      autoUpdateInputs = lib.mkOption {
        type = with lib.types; listOf str;
        default = ["nixpkgs"];
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
          type = lib.types.int;
          default = 4;
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
          experimental-features = ["nix-command" "flakes"];
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
      system.autoUpgrade = {
        enable = true;
        flake = cfg.flake;
        flags = lib.optional (!hasFlake) "--upgrade-all";
      };
      systemd.services.nixos-upgrade = lib.mkMerge [
        checkNetwork
        {
          personal.monitor = true;
        }
      ];
    })

    (lib.mkIf hasFlake {
      systemd.services.flake-update = lib.mkIf hasFlakeInputs (lib.mkMerge [
        checkNetwork
        {
          unitConfig.Description = "Update flake inputs";
          serviceConfig = {
            ExecStart = "${config.nix.package}/bin/nix flake update --commit-lock-file --flake ${cfg.flake} " + lib.concatStringsSep " " cfg.autoUpgrade.autoUpdateInputs;
            Type = "oneshot"; # Ensure that it finishes before starting nixos-upgrade
          };
          before = ["nixos-upgrade.service"];
          wantedBy = ["nixos-upgrade.service"];
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

    (lib.mkIf cfg.remoteBuilds.enable {
      nix = {
        distributedBuilds = true;
        settings.builders-use-substitutes = true;
        buildMachines = with cfg.remoteBuilds.machines.hephaistos;
          lib.optional enable {
            inherit protocol speedFactor;
            hostName = "hephaistos.${domain}";
            system = "x86_64-linux";
            maxJobs = 4;
            supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
            mandatoryFeatures = [];
          };
      };

      programs.ssh = with cfg.remoteBuilds.machines.hephaistos; {
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
    })
  ]);
}
