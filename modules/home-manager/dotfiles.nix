{ lib, ... }:

{
  options.personal.home.dotfiles = lib.mkOption {
    type = with lib.types; attrsOf path;
    default = {};
    description = ''
      Paths to dotfiles.
    '';
    example =
      lib.literalExample "{ \"init.el\" = ./dotfiles/init.el; }";
  };
}
