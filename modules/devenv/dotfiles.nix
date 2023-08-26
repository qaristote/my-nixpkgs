{
  config,
  lib,
  ...
}: let
  cfg = config.dotfiles;
  dotfilesToIgnore = lib.attrNames (lib.filterAttrs (_: {gitignore, ...}: gitignore) cfg);
in {
  options.dotfiles = lib.mkOption {
    type = with lib.types;
    # this cannot be a lazyAttrsOf, see https://nixos.org/manual/nixos/unstable/#sec-option-types-composed
      attrsOf (submodule {
        options = {
          gitignore =
            lib.mkEnableOption ""
            // {
              default = true;
              description = "Whether git should ignore this dotfile, typically if it is generated to contain absolute paths.";
            };
          text = lib.mkOption {
            type = lib.types.lines;
            default = "";
            description = "The content of the dotfile.";
          };
        };
      });
  };

  config.enterShell =
    lib.mkIf (cfg != {})
    (''
        echo Installing dotfiles...
      ''
      + lib.concatStringsSep "\n" (lib.mapAttrsToList (
          name: {
            text,
            gitignore,
          }:
          # this has to be done here to avoid infinite recursion
          let
            content =
              text
              + lib.optionalString (name == ".gitignore") ''
                # dotfiles
                ${lib.concatStringsSep "\n" dotfilesToIgnore}
              '';
          in ''
            ${
              if gitignore
              then "ln -s"
              else "cp"
            } "${builtins.toFile name content}" "${name}"
          ''
        )
        cfg));
}
