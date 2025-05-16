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
  disabledModules = [(devenv.modules + "/languages/nix.nix")];

  options.languages.nix = {
    enable = lib.mkEnableOption "tools for nix development";
    formatter = lib.mkPackageOption pkgs "nix formatter" {
      default = ["alejandra"];
    };
    packaging.enable = lib.mkEnableOption "tools for writing nix derivations";
  };

  config = lib.mkIf cfg.enable {
    packages = with pkgs; [cfg.formatter deadnix] ++ lib.optionals cfg.packaging.enable [nix-prefetch-scripts nix-prefetch-github];

    git-hooks.hooks = {
      deadnix.enable = lib.mkDefault true;
      "${cfg.formatter.pname}".enable = lib.mkDefault true;
    };

    scripts."${cfg.formatter.pname}-emacs".exec = "${cfg.formatter.pname} " + lib.optionalString (cfg.formatter.pname == "alejandra") "--quiet" + " $@";
    emacs.dirLocals.nix-mode.nix-nixfmt-bin = ''"${cfg.formatter.pname}-emacs"'';
  };
}
