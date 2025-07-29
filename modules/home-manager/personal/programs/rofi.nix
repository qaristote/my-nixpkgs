{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.rofi = {
    cycle = lib.mkDefault true;
    theme = lib.mkIf (config.lib ? stylix) (
      lib.mkForce (
        config.lib.stylix.colors {
          template = builtins.readFile config.personal.home.dotfiles.rofi;
          extension = ".rasi";
        }
      )
    );
    plugins = with pkgs; [
      rofi-top
      rofi-calc
      rofi-emoji
    ];
  };
  xdg.dataFile."rofi/themes/custom.rasi" = lib.mkForce {
    source = config.programs.rofi.theme;
    text = null;
  };
}
