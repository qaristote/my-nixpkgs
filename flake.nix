{
  outputs = { self, nur, ... }: {
    nixosModules.personal = import ./modules/nixos;
    overlays = {
      default = self.overlays.personal;
      personal = self: super: {
        personal = (if super ? personal then super.personal else { })
          // import ./pkgs (self.extend nur.overlay);
      };
    };
  };
}
