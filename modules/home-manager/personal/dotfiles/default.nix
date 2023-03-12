{ ... }:

{
  personal.home.dotfiles = {
    latexmkrc = ./latexmkrc;
    rofi = ./rofi.rasi.mustache;
    spacemacs = ./spacemacs.el;
    venv-manager = ./venv-manager.nix;
  };
}
