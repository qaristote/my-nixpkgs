{
  config,
  lib,
  pkgs,
  ...
} @ extraArgs: let
  cfg = config.personal.programs.devenv;
  importedDevenv = extraArgs ? devenv;
in {
  options.personal.programs.devenv.enable = lib.mkEnableOption "devenv";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = importedDevenv;
        message = "attribute devenv missing: add it in home-manager's special args, or set config.personal.devenv.enable to false";
      }
    ];
    home.packages = lib.optional importedDevenv extraArgs.devenv.packages.${pkgs.system}.devenv;
  };
}
