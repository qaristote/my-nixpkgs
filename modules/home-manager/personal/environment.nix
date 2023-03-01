{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [ coreutils moreutils ];
  personal.home.wallpaper =
    lib.mkDefault pkgs.personal.static.wallpapers.nga-1973-68-1;

  programs.bash = { enable = lib.mkDefault true; };

  home = {
    shellAliases = {
      amimullvad = "curl -Ls https://am.i.mullvad.net/connected";
      rm = "rm -f";
      ssh = "TERM=xterm-256color ssh";
      edit = "$EDITOR";
    };
    sessionVariables = { CDPATH = "~"; };
  };
}
