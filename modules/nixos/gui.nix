{ config, lib, pkgs, ... }:

let cfg = config.personal.gui;
in {
  options.personal.gui = {
    enable = lib.mkEnableOption "GUI";
    xserver.enable = lib.mkEnableOption "X server";
    i3.enable = lib.mkEnableOption "i3";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      services.xserver = lib.mkIf cfg.xserver.enable {
        enable = true;
        desktopManager.xfce.enable = true;
        displayManager = {
          lightdm = {
            enable = true;
            # background = background-image;
            greeters.gtk = {
              enable = true;
              # extraConfig = ''
              #   user-background = false
              # '';
              theme = {
                name = "Arc-Dark";
                package = pkgs.arc-theme;
              };
              iconTheme = {
                name = "Breeze-dark";
                package = pkgs.breeze-icons;
              };
            };
          };
        };
        # Hardware
        libinput.enable = true;
        layout = config.personal.hardware.keyboard.keyMap;
        autoRepeatDelay = 200;
      };
      services.blueman.enable = config.hardware.bluetooth.enable;
    }
    (lib.mkIf cfg.i3.enable {
      services.xserver = {
        desktopManager.xfce = {
          noDesktop = true;
          enableXfwm = false;
        };
        windowManager.i3.enable = true;
        displayManager.defaultSession = "xfce+i3";
      };
    })
  ]);
}
