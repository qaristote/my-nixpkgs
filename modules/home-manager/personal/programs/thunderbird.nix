{
  config,
  lib,
  pkgs,
  ...
}: let
  configDefault =
    builtins.readFile "${pkgs.personal.static.userjs.thunderbird}"
    + pkgs.lib.personal.toUserJS {
      # 0391
      "mail.bii.alert.show_preview" = false;
      # 0610
      "browser.send_pings" = false;
      # 905
      # fixes calendar auth
      "network.auth.subresource-http-auth-allow" = 2;
      # 5004
      "permissions.memory_only" = false;
      # 5016
      "browser.download.folderList" = 1;
      # 9000
      "app.update.auto" = false;
      # 9131
      "extensions.cardbook.useOnlyEmail" = false;
      # 9312
      "calendar.timezone.local" = "Europe/Paris";
      # Personal
      ## Default sorting
      "mailnews.default_sort_order" = 2; # Descending
      "mailnews.default_sort_type" = 22; # By thread
      ## Calendar
      "calendar.week.start" = 1;
      "calendar.view.visiblehours" = 16;
      "calendar.dayendhour" = 24;
      ## Duplicates
      "mail.server.default.dup_action" = 1; # delete
      ## Spam
      "mail.spam.manualMark" = true; # move manually marked-as-junk to junk folder
    };
in {
  config = lib.mkMerge [
    {
      programs.thunderbird = {
        profiles.default = {
          isDefault = true;
          withExternalGnupg = true;
        };
      };
    }
    (lib.mkIf config.programs.thunderbird.enable {
      home.file.".thunderbird/default/user.js".text = configDefault;
      xdg.mimeApps.defaultApplications."x-scheme-handler/mailto" = ["thunderbird.desktop"];
    })
  ];
}
