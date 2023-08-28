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
      imports = [
        inputs.devenv.flakeModule
      ];
      systems = ["x86_64-linux" "i686-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];
      perSystem = {...}: {
        devenv.shells.default = {
          imports = [my-nixpkgs.devenvModules.personal];

          ######################## PUT YOUR CONFIG HERE ########################
          # for this flake
          languages.nix.enable = true;
        };
      };
    };
}
