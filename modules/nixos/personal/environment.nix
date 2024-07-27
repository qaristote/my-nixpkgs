{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.personal.environment;
in {
  options.personal.environment = {
    enable = lib.mkEnableOption "basic environment";
    locale.enable = lib.mkEnableOption "French locale";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      environment = {
        systemPackages = with pkgs; [vim gitMinimal busybox coreutils];
        variables.EDITOR = "vim";
      };

      programs.starship.enable = true;
      programs.bash.shellInit = ''
        function set_win_title(){
          echo -ne "\033]0;$(whoami)@$(hostname --long):$(dirs)\a"
        }
        starship_precmd_user_func="set_win_title"
      '';
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
