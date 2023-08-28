{
  mkDevenv = {
    devenv,
    flake-parts,
    my-nixpkgs,
    ...
  } @ inputs: config:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [devenv.flakeModule];
      systems = ["x86_64-linux" "i686-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];
      perSystem = _: {
        devenv.shells.default = {
          imports = [my-nixpkgs.devenvModules.personal config];
        };
      };
    };
}
