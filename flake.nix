{
  outputs = { self }: {
    nixosModules.personal = import ./modules/nixos;
  };
}
