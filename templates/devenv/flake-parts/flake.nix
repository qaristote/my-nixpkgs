{
  inputs = {
    devenv.url = "github:cachix/devenv";
    my-nixpkgs.url = "github:qaristote/my-nixpkgs";
    nixpkgs = {};
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-trusted-substituters = "https://devenv.cachix.org";
  };

  outputs = {
    flake-parts,
    my-nixpkgs,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = with my-nixpkgs.flakeModules; [personal devenv];
      perSystem = {...}: {
        devenv.shells.default = {
          ######################## PUT YOUR CONFIG HERE ########################
          languages.nix.enable = true;
        };
      };
    };
}
