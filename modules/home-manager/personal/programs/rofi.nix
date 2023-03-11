{ config, lib, pkgs, ... }:

{
  programs.rofi = {
    cycle = lib.mkDefault true;
    theme = lib.mkDefault config.personal.home.dotfiles.rofi;
    # TODO: remove this when stylix fixes it upstream
    font = lib.mkIf (config ? stylix) (lib.mkForce "${config.stylix.fonts.monospace.name} 12");
    plugins = with pkgs; [ rofi-top rofi-calc rofi-emoji ];
  };
}
