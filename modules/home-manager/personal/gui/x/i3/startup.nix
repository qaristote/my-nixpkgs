{
  config,
  lib,
  ...
}: {
  xsession.windowManager.i3.config.startup = let
    autostart = {
      command,
      always ? false,
      notification ? false,
    }: {
      inherit command always notification;
    };
    autostartIf = cond: args: lib.optional cond (autostart args);
  in
    [
      (autostart {command = "rfkill block bluetooth";})
      (autostart {command = "keepassxc";})
    ]
    ++ autostartIf config.programs.thunderbird.enable {command = "thunderbird";}
    ++ autostartIf
    (config.personal.profiles.social && config.personal.identities.personal) {
      command = "signal-desktop";
    };
}
