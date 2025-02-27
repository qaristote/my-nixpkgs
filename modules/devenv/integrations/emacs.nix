{
  config,
  lib,
  ...
}: let
  cfg = config.emacs;
  attrs2alist = value:
    if lib.isAttrs value
    then "(${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: "(${name} . ${attrs2alist value})") value)})"
    else
      (
        if lib.isList value
        then "(${lib.concatStringsSep " " value})"
        else
          (
            if lib.isBool value
            then
              (
                if value
                then "t"
                else "nil"
              )
            else builtins.toString value
          )
      );
in {
  options.emacs = {
    enable = lib.mkEnableOption "emacs integration";
    dirLocals = lib.mkOption {
      type = with lib.types; attrsOf (attrsOf anything);
      default = {};
      example =
        # the first example from https://www.gnu.org/software/emacs/manual/html_node/emacs/Directory-Variables.html
        {
          nil = {
            indent-tabs-mode = true;
            fill-column = 80;
            mode = "auto-fill";
          };
          c-mode = {
            c-file-style = ''"BSD"'';
            subdirs = "nil";
          };
          "\"src/imported\"".nil.change-log-default-name = ''"ChangeLog.local"'';
        };
    };
  };

  config.dotfiles.".dir-locals.el".text =
    lib.mkIf (cfg.dirLocals != {})
    (attrs2alist cfg.dirLocals);
}
