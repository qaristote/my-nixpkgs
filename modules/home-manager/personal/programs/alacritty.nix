{ config, lib, ... }:

{
  programs.alacritty.settings = {
      window = {
        padding = {
          x = 10;
          y = 10;
        };
        dimensions = {
          lines = 75;
          columns = 100;
        };
      };

      font = lib.mkForce { size = 8.0; };
  };

  xsession.windowManager.i3.config.terminal = lib.mkIf config.programs.alacritty.enable "alacritty";
}
  
