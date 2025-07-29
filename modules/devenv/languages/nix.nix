{
  config,
  options,
  lib,
  pkgs,
  devenv,
  ...
}:
let
  cfg = config.languages.nix;
in
{
  disabledModules = [ (devenv.modules + "/languages/nix.nix") ];

  options.languages.nix = {
    enable = lib.mkEnableOption "tools for nix development";
    formatter = lib.mkPackageOption pkgs "nix formatter" { default = [ "nixfmt" ]; };
    packaging.enable = lib.mkEnableOption "tools for writing nix derivations";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        packages =
          with pkgs;
          [
            cfg.formatter
            deadnix
          ]
          ++ lib.optionals cfg.packaging.enable [
            nix-prefetch-scripts
            nix-prefetch-github
          ];

        git-hooks.hooks =
          let
            formatterHookname = with cfg.formatter; if pname == "nixfmt" then "nixfmt-rfc-style" else pname;
          in
          {
            deadnix.enable = lib.mkDefault true;
            "${formatterHookname}".enable = lib.mkDefault true;
          };
      }
      (lib.mkIf (cfg.formatter.pname == "alejandra") {
        scripts."alejandra-emacs".exec = "alejandra --quiet $@";
        emacs.dirLocals.nix-mode.nix-nixfmt-bin = ''"alejandra-emacs"'';
      })
    ]
  );
}
