{
  inputs.devenv = {
    url = "github:cachix/devenv";
    inputs.nixpkgs.url = "nixpkgs";
  };

  outputs = {
    self,
    nur,
    nixpkgs,
    flake-parts,
    devenv,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [flake-parts.flakeModules.easyOverlay devenv.flakeModule];
      systems = ["x86_64-linux" "i686-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];

      flake = {
        devenvModules.personal = import ./modules/devenv;
        nixosModules.personal = import ./modules/nixos;
        homeModules.personal = import ./modules/home-manager;
        overlays.personal = self.overlays.default;
      };

      perSystem = {
        config,
        system,
        pkgs,
        lib,
        ...
      }: {
        _module.args.pkgs = import nixpkgs {
          inherit system;
          overlays = [nur.overlay];
          config = {};
        };

        overlayAttrs = {
          inherit
            (lib.recursiveUpdate pkgs {
              personal = config.packages;
              lib.personal = config.packages.lib;
            })
            personal
            lib
            ;
        };
        packages = import ./pkgs pkgs;

        devenv.shells.default = {
          imports = [self.devenvModules.personal];
          languages.nix.enable = true;
        };
      };
    };
}
