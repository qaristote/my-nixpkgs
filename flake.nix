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
  } @ inputs: let
    devenvModules.personal = import ./modules/devenv;
    flakeModules = {
      personal = import ./modules/flake-parts/personal.nix;
      devenv = import ./modules/flake-parts/devenv.nix devenvModules;
    };
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = builtins.attrValues flakeModules;
      flake = {
        inherit devenvModules flakeModules;
        nixosModules.personal = import ./modules/nixos;
        homeModules.personal = import ./modules/home-manager;
        overlays.personal = _: super: let
          my-packages = import ./pkgs (super.extend nur.overlay);
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
          mkDevenvTemplate = path: {inherit welcomeText path;};
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
            if lib.isAttrs attrs && !lib.isDerivation attrs
            then
              lib.foldlAttrs
              (prev: name: value: prev // aux (path ++ [name]) value) {}
              attrs
            else
              (
                if lib.isDerivation attrs
                then {
                  "${lib.concatStringsSep "_" path}" = attrs;
                }
                else {}
              );
        in
          aux [];
      in {
        _module.args.pkgs = import nixpkgs {
          inherit system;
          overlays = [self.overlays.personal];
          config = {};
        };

        packages = flatten pkgs.personal;

        devenv.shells.default = {
          languages.nix = {
            enable = true;
            packaging.enable = true;
          };
        };
      };
    };
}
