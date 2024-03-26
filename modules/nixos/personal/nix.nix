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
    autoUpgrade = lib.mkEnableOption "automatic system and nixpkgs upgrade";
    flake = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
    };
    gc.enable = lib.mkEnableOption "garbage collection";
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.config = {allowUnfree = true;};
    environment.etc."nix/registry.json".text = lib.mkForce (builtins.toJSON {
      version = 2;
    });
    nix = {
      package = pkgs.nixVersions.unstable;
      settings = {
        auto-optimise-store = true;
        experimental-features = ["nix-command" "flakes"];
        trusted-substituters = ["https://devenv.cachix.org/" "https://nix-community.cachix.org/"];
        trusted-public-keys = ["devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=" "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="];
      };
      gc = lib.mkIf cfg.gc.enable {
        automatic = true;
        dates = "daily";
        options = "--delete-old";
      };
    };
    system.autoUpgrade = lib.mkIf cfg.autoUpgrade {
      enable = true;
      flake = cfg.flake;
      flags =
        if (cfg.flake == null)
        then ["--upgrade-all"]
        else ["--commit-lock-file"] ++ pkgs.personal.lib.updateInputFlag "nixpkgs";
    };
    systemd.services = {
      nixos-upgrade.personal.monitor = true;
      nix-gc = {
        after =
          lib.optional (cfg.autoUpgrade && cfg.gc.enable)
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
    };
    programs.git = lib.mkIf (cfg.flake != null && lib.hasPrefix "git+file" cfg.flake) {
      enable = true;
      config.user = {
        name = "Root user of ${config.networking.hostName}";
        email = "root@${config.networking.hostName}";
      };
    };
  };
}
