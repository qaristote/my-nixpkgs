{
  outputs = { self, nur, ... }: {
    nixosModules.personal = import ./modules/nixos;
    homeModules.personal = import ./modules/home-manager;
    overlays = {
      default = self.overlays.personal;
      personal = self: super:
        let personal-pkgs = import ./pkgs (self.extend nur.overlay);
        in {
          personal = (super.personal or { }) // personal-pkgs;
          lib = (super.lib or { }) // {
            personal = (super.lib.personal or { }) // personal-pkgs.lib;
          };
        };
    };
  };
}
