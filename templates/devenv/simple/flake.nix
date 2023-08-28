{
  inputs = {
    devenv.url = "github:cachix/devenv";
    my-nixpkgs.url = "github:qaristote/my-nixpkgs";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-trusted-substituters = "https://devenv.cachix.org";
  };

  outputs = {my-nixpkgs, ...} @ inputs:
    my-nixpkgs.lib.mkDevenv inputs
    # this function has the same arguments flake-parts' perSystem does:
    # config, lib, pkgs, system, etc.
    ({...}: {
      # put your devenv configuration  here
      languages.nix.enable = true;
    });
}
