{ config, lib, pkgs, ... }:

let
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
  brightnessctlKbd = "${brightnessctl} --device dell:kbd_backlight";
  volumectl = "${pkgs.pulseaudio}/bin/pactl";
  screenshot = "${pkgs.shutter}/bin/shutter";

  modifier = "Mod4";
in {
  xsession.windowManager.i3.config = {
    inherit modifier;

    keybindings = lib.mkOptionDefault {
      # launching apps
      "${modifier}+Control+Return" = ''exec "emacsclient --create-frame"'';
      "${modifier}+Shift+Return" = ''exec "$BROWSER"'';
      "${modifier}+d" = lib.mkIf config.programs.rofi.enable
        ''exec "rofi -modi drun,filebrowser,run,window -show drun"'';

      # exiting
      "${modifier}+Shift+e" = "exec i3-msg exit";
      "${modifier}+l" =
        "exec ${config.personal.home.lockscreen}/bin/lockscreen.sh";

      # media keys
      "XF86MonBrightnessUp" = "exec ${brightnessctl} set 5%+";
      "XF86MonBrightnessDown" = "exec ${brightnessctl} set 5%-";
      "XF86AudioRaiseVolume" =
        "exec ${volumectl} set-sink-volume @DEFAULT_SINK@ +5%";
      "XF86AudioLowerVolume" =
        "exec ${volumectl} set-sink-volume @DEFAULT_SINK@ -5%";
      "XF86AudioMute" = "exec ${volumectl} set-sink-mute @DEFAULT_SINK@ toggle";
      "Shift+XF86AudioRaiseVolume" =
        "exec ${volumectl} set-source-volume @DEFAULT_SOURCE@ +5%";
      "Shift+XF86AudioLowerVolume" =
        "exec ${volumectl} set-source-volume @DEFAULT_SOURCE@ -5%";
      "XF86AudioMicMute" =
        "exec ${volumectl} set-source-mute @DEFAULT_SOURCE@ toggle";
      "XF86KbdBrightnessUp" = ''
        exec ${brightnessctlKbd} set \
             $(( $(${brightnessctlKbd} max) - $(${brightnessctlKbd} get) ))
      '';
      "Print" = "exec ${screenshot}";
    };
  };
}
