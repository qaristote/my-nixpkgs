{ config, lib, pkgs, ... }:

let cfg = config.personal.nix;
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
    nixpkgs.config = { allowUnfree = true; };
    nix = {
      settings = {
        auto-optimise-store = true;
        experimental-features = [ "nix-command" "flakes" ];
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
      flags = if (cfg.flake == null) then
        [ "--upgrade-all" ]
      else
        [ "--commit-lock-file" ] ++ pkgs.personal.lib.updateInputFlag "nixpkgs";
    };
    systemd.services = {
      nix-gc.after =
        lib.optional (cfg.autoUpgrade && cfg.gc.enable) "nixos-upgrade.service";
      nix-gc-remove-dead-roots = {
        enable = cfg.gc.enable;
        description = "Remove dead symlinks in /nix/var/nix/gcroots";
        serviceConfig.Type = "oneshot";
        script = "find /nix/var/nix/gcroots -xtype l -delete";
        before = lib.mkIf config.nix.gc.automatic [ "nix-gc.service" ];
        wantedBy = lib.mkIf config.nix.gc.automatic [ "nix-gc.service" ];
      };
    };
  };
}
