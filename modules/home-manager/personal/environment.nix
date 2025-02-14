{
  config,
  lib,
  pkgs,
  ...
} @ inputs: {
  home.packages = with pkgs; [coreutils moreutils];
  personal.home.wallpaper =
    lib.mkDefault (inputs.osConfig.stylix.image or (pkgs.personal.static.wallpapers.nga-1973-68-1.override {gravity = "north";}));

  programs.bash = {enable = lib.mkDefault true;};

  home = {
    shellAliases = {
      amimullvad = "curl -Ls https://am.i.mullvad.net/connected";
      rm = "rm -f";
      ssh = "TERM=xterm-256color ssh";
      edit = "$EDITOR";
    };
    sessionVariables = {
      CDPATH = "~";
      DO_NOT_TRACK = "1";
    };
  };

  programs.bash.bashrcExtra = ''
    function set_win_title(){
      echo -ne "\033]0;$(whoami)@$(hostname):$(dirs)\a"
    }
    starship_precmd_user_func="set_win_title"
  '';

  services.gpg-agent = {
    enableBashIntegration = lib.mkDefault config.programs.bash.enable;
    pinentryPackage = lib.mkDefault (
      if config.personal.gui.enable
      then pkgs.pinentry-qt
      else null
    );
    grabKeyboardAndMouse =
      lib.mkDefault false; # insecure, but necessary with keepass auto-type
  };
}
