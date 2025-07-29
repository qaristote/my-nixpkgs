{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.gitignore;
  ignoreDevenv = cfg.devenv.enable or false;
  templates = lib.attrNames (
    lib.filterAttrs (name: value: (value.enable or false) && name != "devenv") cfg
  );
  toUncomment = builtins.concatLists (lib.collect lib.isList cfg);
in
{
  options.gitignore = lib.mkOption {
    type =
      with lib.types;
      (submodule {
        freeformType =
          with lib.types;
          attrsOf (submodule {
            options = {
              enable = lib.mkEnableOption "";
              uncomment = lib.mkOption {
                type = with lib.types; listOf str;
                default = [ ];
                description = "Lines that should be uncommented and thus enabled in the template file.";
              };
            };
          });
        options.extra = lib.mkOption {
          type = lib.types.lines;
          default = "";
          example = ''
            *.my-file-extension
          '';
        };
      });
    default = {
      extra = "";
    };
  };

  config = {
    dotfiles.".gitignore" = lib.mkIf (templates != { } || cfg.extra != "") {
      gitignore = lib.mkDefault false;
      text =
        lib.optionalString (templates != [ ]) (
          builtins.readFile (
            (pkgs.extend inputs.my-nixpkgs.overlays.personal).personal.static.gitignore.override {
              inherit templates toUncomment;
            }
          )
        )
        + lib.optionalString ignoreDevenv ''
          ### devenv
          .devenv/
          .devenv.flake.nix
          devenv.local.nix
          .pre-commit-config.yaml
        ''
        + lib.optionalString (cfg.extra != "") ''
          ### miscellaneous
          ${cfg.extra}
        '';
    };
    gitignore.devenv.enable = lib.mkDefault true;
  };
}
