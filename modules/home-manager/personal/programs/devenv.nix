{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.personal.programs.devenv;
  importedDevenv = pkgs ? devenv;
in
{
  options.personal.programs.devenv.enable = lib.mkEnableOption "devenv";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = importedDevenv;
        message = "package devenv missing: add it in a nixpkgs overlay, or set config.personal.devenv.enable to false";
      }
    ];
    home.packages = lib.optional importedDevenv pkgs.devenv;
  };
}
