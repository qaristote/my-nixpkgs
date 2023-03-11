{ config, lib, pkgs, ... }:

let
  # i3 pretty-printing
  exec = script: ''exec "${script}";'';
  execRofiShow = modi: exec "${rofiShow} ${modi}";
  modifier = "Mod4";
  mkTempMode = lib.mapAttrs (_: value: "mode default; ${value}");

  # scripts
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
  brightnessctlKbd = "${brightnessctl} --device dell:kbd_backlight";
  volumectl = "${pkgs.pulseaudio}/bin/pactl";
  screenshot = "${pkgs.shutter}/bin/shutter";
  rofiShow = "rofi -show";
  rofiPulseSelect = "${pkgs.rofi-pulse-select}/bin/rofi-pulse-select";
  rofiBluetooth = "${pkgs.rofi-bluetooth}/bin/rofi-bluetooth";
  rofiPowerMenu = "${pkgs.rofi-power-menu}/bin/rofi-power-menu";
in {
  xsession.windowManager.i3.config = {
    inherit modifier;

    modes = lib.mkOptionDefault {
      # launching apps
      launch = mkTempMode ({
        "e" = exec "emacsclient --create-frame";
        "b" = exec "$BROWSER";
      } // lib.optionalAttrs config.programs.rofi.enable {
        "c" = execRofiShow "calc";
        "d" = execRofiShow "drun";
        "f" = execRofiShow "filebrowser";
        "m" = execRofiShow "emoji";
        "r" = execRofiShow "run";
        "t" = execRofiShow "top";
        "w" = execRofiShow "window";
        "Escape" = "";
      });
    };

    keybindings = lib.mkOptionDefault ({
      "${modifier}+space" = "mode launch";
    } // lib.optionalAttrs config.programs.rofi.enable {
      "${modifier}+F1" = exec "${rofiPulseSelect} sink";
      "${modifier}+F4" = exec "${rofiPulseSelect} source";
      "${modifier}+Print" = exec rofiBluetooth;
      "${modifier}+Delete" =
        exec "${rofiShow} menu -modi menu:${rofiPowerMenu}";
    } // {

      # exiting
      "${modifier}+Shift+e" = exec "i3-msg exit";
      "${modifier}+l" = exec config.personal.home.lockscreen;

      # media keys
      "XF86MonBrightnessUp" = exec "${brightnessctl} set 5%+";
      "XF86MonBrightnessDown" = exec "${brightnessctl} set 5%-";
      "XF86AudioRaiseVolume" =
        exec "${volumectl} set-sink-volume @DEFAULT_SINK@ +5%";
      "XF86AudioLowerVolume" =
        exec "${volumectl} set-sink-volume @DEFAULT_SINK@ -5%";
      "XF86AudioMute" = "exec ${volumectl} set-sink-mute @DEFAULT_SINK@ toggle";
      "Shift+XF86AudioRaiseVolume" =
        exec "${volumectl} set-source-volume @DEFAULT_SOURCE@ +5%";
      "Shift+XF86AudioLowerVolume" =
        exec "${volumectl} set-source-volume @DEFAULT_SOURCE@ -5%";
      "XF86AudioMicMute" =
        exec "${volumectl} set-source-mute @DEFAULT_SOURCE@ toggle";
      "XF86KbdBrightnessUp" = ''
        exec {brightnessctlKbd} set \
                             $(( $(${brightnessctlKbd} max) - $(${brightnessctlKbd} get) ))
      '';
      "Print" = exec screenshot;
    });
  };
}
