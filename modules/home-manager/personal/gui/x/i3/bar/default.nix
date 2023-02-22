{ config, lib, pkgs, ... }@extraArgs:

let
  statusPackage =
    pkgs.personal.barista.override { i3statusGo = ./i3status.go; };
in {
  xsession.windowManager.i3.config.bars = [{
    statusCommand = "${statusPackage}/bin/i3status";
    fonts = {
      names = [ "roboto" ];
      size = 11.0;
    };
    colors.background = "#111111";
  }];

  home.packages = with pkgs;
    lib.optionals
    (config.xsession.enable && config.xsession.windowManager.i3.enable) [
      material-design-icons
      roboto
      # source-code-pro
    ];

  # (Miscellaneous) Tray icons
  services.blueman-applet.enable =
    lib.mkDefault (extraArgs.osConfig.services.blueman.enable);
}
