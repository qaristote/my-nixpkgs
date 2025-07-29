{
  outputs =
    {
      self,
      nur,
      nixpkgs,
      flake-parts,
      ...
    }@inputs:
    let
      devenvModules.personal = ./modules/devenv;
      flakeModules = {
        personal = ./modules/flake-parts/personal.nix;
        devenv = import ./modules/flake-parts/devenv.nix devenvModules;
      };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ flakeModules.personal ];
      flake = {
        inherit devenvModules flakeModules;
        nixosModules.personal = ./modules/nixos;
        homeModules.personal = ./modules/home-manager;
        overlays.personal =
          _: super:
          let
            my-packages = import ./pkgs (super.extend nur.overlays.default);
          in
          {
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

        templates =
          let
            devenv = {
              path = ./templates/devenv;
            };
          in
          {
            inherit devenv;
            default = devenv;
          };
      };

      perSystem =
        {
          config,
          system,
          pkgs,
          lib,
          ...
        }:
        let
          flatten =
            let
              aux =
                path: attrs:
                if lib.isAttrs attrs && !lib.isDerivation attrs then
                  lib.foldlAttrs (
                    prev: name: value:
                    prev // aux (path ++ [ name ]) value
                  ) { } attrs
                else
                  (
                    if lib.isDerivation attrs then
                      {
                        "${lib.concatStringsSep "_" path}" = attrs;
                      }
                    else
                      { }
                  );
            in
            aux [ ];
        in
        {
          _module.args.pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlays.personal ];
            config = { };
          };

          packages = flatten pkgs.personal;
        };
    };
}
