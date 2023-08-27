{
  inputs.devenv = {
    url = "github:cachix/devenv";
    inputs.nixpkgs.url = "nixpkgs";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-trusted-substituters = "https://devenv.cachix.org";
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
        overlays.personal = _: super: let
          my-packages = import ./pkgs super;
        in {
          inherit
            (super.lib.recursiveUpdate super {
              personal = my-packages;
              lib.personal = my-packages.lib;
            })
            personal
            lib
            ;
        };

        lib = import ./lib;

        templates = let
          welcomeText = ''
            # `.devenv` should be added to `.gitignore`
            ```sh
              echo .devenv >> .gitignore
            ```
          '';
          mkDevenvTemplate = path: {
            inherit welcomeText path;
          };
          devenv = mkDevenvTemplate ./templates/devenv/simple;
          devenvModular = mkDevenvTemplate ./templates/devenv/flake-parts;
        in {
          inherit devenv devenvModular;
          default = devenv;
        };
      };

      perSystem = {
        config,
        system,
        pkgs,
        lib,
        ...
      }: let
        flatten = let
          aux = path: attrs:
            if lib.isAttrs attrs && ! lib.isDerivation attrs
            then lib.foldlAttrs (prev: name: value: prev // aux (path ++ [name]) value) {} attrs
            else
              (
                if lib.isDerivation attrs
                then {"${lib.concatStringsSep "_" path}" = attrs;}
                else {}
              );
        in
          aux [];
      in {
        _module.args.pkgs = import nixpkgs {
          inherit system;
          overlays = [nur.overlay self.overlays.personal];
          config = {};
        };

        packages = flatten pkgs.personal;

        devenv.shells.default = {
          imports = [self.devenvModules.personal];
          languages.nix = {
            enable = true;
            packaging.enable = true;
          };
        };
      };
    };
}
