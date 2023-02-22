{ config, lib, pkgs, ... }:

{
  xsession.windowManager.i3.config.startup = let
    autostart = { command, always ? false, notification ? false }: {
      inherit command always notification;
    };
    autostartIf = cond: args: lib.optional cond (autostart args);
  in [
    (autostart { command = "rfkill block bluetooth"; })
    (autostart { command = "keepassxc"; })
  ]
  ++ autostartIf config.programs.thunderbird.enable { command = "thunderbird"; }
  ++ autostartIf config.personal.profiles.social { command = "signal-desktop"; }
  # ++ autostartIf config.services.redshift.enable {
  #   command = "systemctl --user start redshift";
  # }
  ++ autostartIf (config.personal.home.wallpaper != null) {
    command = "${pkgs.feh}/bin/feh --bg-scale ${config.personal.home.wallpaper}";
  }
  # ++ autostartIf config.services.xidlehook.enable {
  #   command = "systemctl --user start xidlehook.service";
  # }
  ;
}
