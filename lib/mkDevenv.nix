{
  devenv,
  flake-parts,
  my-nixpkgs,
  ...
}@inputs:
config:
flake-parts.lib.mkFlake { inherit inputs; } {
  imports = builtins.attrValues { inherit (my-nixpkgs.flakeModules) personal devenv; };
  perSystem = _: {
    devenv.shells.default = {
      imports = [ config ];
    };
  };
}
