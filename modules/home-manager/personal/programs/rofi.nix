{ config, lib, ... }:

{
  programs.rofi = {
    cycle = lib.mkDefault true;
    theme = lib.mkDefault config.personal.home.dotfiles.rofi;
  };
}
