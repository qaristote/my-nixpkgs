{
  outputs = { self, flake-utils, nur, nixpkgs, ... }:
    {
      nixosModules.personal = import ./modules/nixos;
      homeModules.personal = import ./modules/home-manager;
      overlays = {
        default = self.overlays.personal;
        personal = self: super:
          let personalPackages = import ./pkgs (super.extend nur.overlay);
          in {
            personal = (super.personal or { }) // personalPackages;
            lib = (super.lib or { }) // {
              personal = (super.lib.personal or { }) // personalPackages.lib;
            };
          };
      };
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ nur.overlay ];
        };
      in { packages = import ./pkgs pkgs; });
}
