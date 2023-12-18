{
  config,
  lib,
  pkgs,
  ...
} @ inputs: {
  home.packages = with pkgs; [coreutils moreutils];
  personal.home.wallpaper =
    lib.mkDefault (inputs.osConfig.stylix.image or pkgs.personal.static.wallpapers.nga-1973-68-1);

  programs.bash = {enable = lib.mkDefault true;};

  home = {
    shellAliases = {
      amimullvad = "curl -Ls https://am.i.mullvad.net/connected";
      rm = "rm -f";
      ssh = "TERM=xterm-256color ssh";
      edit = "$EDITOR";
    };
    sessionVariables = {CDPATH = "~";};
  };

  services.gpg-agent = {
    enableBashIntegration = lib.mkDefault config.programs.bash.enable;
    pinentryFlavor = lib.mkDefault (
      if config.personal.gui.enable
      then "qt"
      else "tty"
    );
    grabKeyboardAndMouse =
      lib.mkDefault false; # insecure, but necessary with keepass auto-type
  };
}
