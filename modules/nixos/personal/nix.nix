{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.personal.nix;
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
  };

  config = lib.mkIf cfg.enable {
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
      gc = lib.mkIf cfg.gc.enable {
        automatic = true;
        dates = "daily";
        options = "--delete-old";
      };
    };

    system.autoUpgrade = lib.mkIf cfg.autoUpgrade.enable {
      enable = true;
      flake = cfg.flake;
      flags = lib.optional (cfg.flake == null) "--upgrade-all";
    };
    systemd.services = lib.mkMerge [
      (lib.mkIf cfg.autoUpgrade.enable {
        # upgrading
        flake-update = lib.mkIf (cfg.flake != null && cfg.autoUpgrade.autoUpdateInputs != []) {
          preStart = "${pkgs.host}/bin/host 9.9.9.9 || exit 100"; # Check network connectivity
          unitConfig = {
            Description = "Update flake inputs";
            StartLimitIntervalSec = 300;
            StartLimitBurst = 5;
          };
          serviceConfig = {
            ExecStart = "${config.nix.package}/bin/nix flake update --commit-lock-file --flake ${cfg.flake} " + lib.concatStringsSep " " cfg.autoUpgrade.autoUpdateInputs;
            RestartForceExitCode = "100";
            RestartSec = "30";
            Type = "oneshot"; # Ensure that it finishes before starting nixos-upgrade
          };
          before = ["nixos-upgrade.service"];
          path = [pkgs.git];
          personal.monitor = true;
        };
        nixos-upgrade = {
          preStart = "${pkgs.host}/bin/host 9.9.9.9 || exit 100"; # Check network connectivity
          unitConfig = {
            StartLimitIntervalSec = 300;
            StartLimitBurst = 5;
          };
          serviceConfig = {
            RestartForceExitCode = "100";
            RestartSec = "30";
          };
          after = ["flake-update.service"];
          wants = ["flake-update.service"];
          personal.monitor = true;
        };
      })
      {
        # cleaning
        nix-gc = {
          after =
            lib.optional (cfg.autoUpgrade.enable && cfg.gc.enable)
            "nixos-upgrade.service";
          personal.monitor = true;
        };
        nix-gc-remove-dead-roots = {
          enable = cfg.gc.enable;
          description = "Remove dead symlinks in /nix/var/nix/gcroots";
          serviceConfig.Type = "oneshot";
          script = "find /nix/var/nix/gcroots -xtype l -delete";
          before = lib.mkIf config.nix.gc.automatic ["nix-gc.service"];
          wantedBy = lib.mkIf config.nix.gc.automatic ["nix-gc.service"];
          personal.monitor = true;
        };
        nix-gc-remove-old-hm-gens = let
          user = config.personal.user;
        in {
          enable = cfg.gc.enable && user.enable && user.homeManager.enable;
          description = "Remove old Home Manager generations for user ${user.name}";
          serviceConfig.Type = "oneshot";
          script = "${pkgs.nix}/bin/nix-env --profile /home/${user.name}/.local/state/nix/profiles/home-manager --delete-generations old";
          before = lib.mkIf config.nix.gc.automatic ["nix-gc.service"];
          wantedBy = lib.mkIf config.nix.gc.automatic ["nix-gc.service"];
          personal.monitor = true;
        };
      }
    ];

    programs.git = lib.mkIf (cfg.flake != null && lib.hasPrefix "git+file" cfg.flake) {
      enable = true;
      config.user = {
        name = "Root user of ${config.networking.hostName}";
        email = "root@${config.networking.hostName}";
      };
    };
  };
}
