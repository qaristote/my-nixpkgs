{
  config,
  options,
  lib,
  pkgs,
  devenv,
  ...
}: let
  cfg = config.languages.nix;
in {
  disabledModules = ["${devenv}/src/modules/languages/nix.nix"];

  options.languages.nix = {
    enable = lib.mkEnableOption "tools for nix development";
    formatter = lib.mkPackageOption pkgs "nix formatter" {
      default = ["alejandra"];
    };
    packaging.enable = lib.mkEnableOption "tools for writing nix derivations";
  };

  config = {
    packages = lib.mkIf cfg.enable (with pkgs; [cfg.formatter deadnix] ++ lib.optionals cfg.packaging.enable [nix-prefetch-scripts nix-prefetch-github]);

    pre-commit.hooks = {
      deadnix.enable = lib.mkDefault true;
      "${cfg.formatter.pname}".enable = lib.mkDefault true;
    };
  };
}
