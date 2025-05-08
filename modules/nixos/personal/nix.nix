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
    gc.enable = lib.mkEnableOption "garbage collection";
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
        registry.my-nixpkgs = {
          from = {
            type = "indirect";
            id = "my-nixpkgs";
          };
          to = {
            type = "github";
            owner = "qaristote";
            repo = "my-nixpkgs";
          };
        };
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
  ]);
}
