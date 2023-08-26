{
  config,
  lib,
  ...
}: let
  cfg = config.gitignore;
in {
  options.gitignore = {
    extra = lib.mkOption {
      type = lib.types.lines;
      default = "";
      example = ''
        *.my-file-extension
      '';
    };
  };

  config.dotfiles.gitignore = lib.mkIf (cfg.extra != "") {
    gitignore = lib.mkDefault false;
    text = ''
      ## Miscellaneous
      ${cfg.extra};
    '';
  };
}
