{
  config,
  lib,
  pkgs,
  ...
} @ extraArgs: let
  cfg = config.personal.gui;
in {
  imports = [./redshift.nix ./x];

  options.personal.gui = {
    enable =
      lib.mkEnableOption "GUI"
      // {
        default = extraArgs.osConfig.personal.gui.enable or false;
      };
  };

  config = lib.mkIf cfg.enable {
    services.kdeconnect.indicator = lib.mkDefault true;

    services.safeeyes.enable = true;

    home.pointerCursor = lib.mkDefault {
      name = "Numix-Cursor-Light";
      package = pkgs.numix-cursor-theme;
    };

    dconf.enable = lib.mkDefault true;
    gtk = {
      enable = lib.mkDefault true;
      theme = lib.mkDefault {
        name = "Arc-Dark";
        package = pkgs.arc-theme;
      };
      iconTheme = lib.mkDefault {
        name = "breeze-dark";
        package = pkgs.kdePackages.breeze-icons;
      };
    };
    qt = {
      enable = lib.mkDefault true;
      platformTheme.name = lib.mkDefault "gtk";
    };

    home.packages =
      lib.optional config.dconf.enable pkgs.dconf
      ++ (with pkgs; [keepassxc pavucontrol]);
    programs.firefox.enable = true;
  };
}
