{
  outputs = { self, flake-utils }: {
    nixosModules.personal = import ./modules/nixos;
    overlays.personal = self: super: {
      personal = import ./pkgs self;
    };
  };
}
