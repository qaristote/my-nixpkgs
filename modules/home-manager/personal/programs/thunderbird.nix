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
      "mail.server.default.dup_action" = 3; # mark as read
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
    })
  ];
}
