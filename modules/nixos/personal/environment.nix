{ config, lib, pkgs, ... }:

let cfg = config.personal.environment;
in {
  options.personal.environment = {
    enable = lib.mkEnableOption "basic environment";
    locale.enable = lib.mkEnableOption "French locale";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      environment.systemPackages = with pkgs; [
        vim
        gitMinimal
        busybox
        coreutils
      ];
    }
    (lib.mkIf cfg.locale.enable {
      time.timeZone = "Europe/Paris";
      i18n = {
        defaultLocale = "fr_FR.utf8";
        extraLocaleSettings.LANG = "en_US.utf8";
      };
      console = {
        font = "Lat2-Terminus16";
        keyMap = config.personal.hardware.keyboard.keyMap;
      };
    })
  ]);
}
