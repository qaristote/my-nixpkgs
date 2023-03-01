{ config, lib, pkgs, ... }@extraArgs:

let
  statusPackage =
    pkgs.personal.barista.override { i3statusGo = ./i3status.go; };
in {
  xsession.windowManager.i3.config.bars = [
    ({
      statusCommand = "${statusPackage}/bin/i3status";
    } // (config.lib.stylix.i3.bar or { colors.background = "#111111"; }) // {
      fonts = {
        names = [ "roboto" ];
        size = 11.0;
      };
    })
  ];

  home.packages = with pkgs;
    lib.optionals
    (config.xsession.enable && config.xsession.windowManager.i3.enable) [
      material-design-icons
      roboto
    ];

  # (Miscellaneous) Tray icons
  services.blueman-applet.enable =
    lib.mkDefault (extraArgs.osConfig.services.blueman.enable);
}
