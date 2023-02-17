{
  outputs = { self, nur, ... }: {
    nixosModules.personal = import ./modules/nixos;
    overlays = {
      default = self.overlays.personal;
      personal = self: super: {
        personal = import ./pkgs (self.extend nur.overlay);
      };
    };
  };
}
