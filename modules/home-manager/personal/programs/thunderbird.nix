{ config, lib, pkgs, ... }:

let
  configDefault = builtins.readFile "${pkgs.personal.thunderbirdUserJS}"
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
    };
  profiles = {
    all = { };
    personal = { };
    work = { };
  };
in {
  config = lib.mkMerge [
    { programs.thunderbird = { inherit profiles; }; }
    (lib.mkIf config.programs.thunderbird.enable {
      home.file = lib.concatMapAttrs
        (name: _: { ".thunderbird/${name}/user.js".text = configDefault; })
        profiles;
    })
  ];
}
