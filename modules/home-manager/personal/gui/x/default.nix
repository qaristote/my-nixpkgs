{
  config,
  lib,
  ...
} @ extraArgs: let
  cfg = config.personal.x;
in {
  imports = [./i3 ./idlehook.nix ./picom.nix];

  options.personal.x = {
    enable =
      lib.mkEnableOption "X"
      // {
        default = extraArgs.osConfig.services.xserver.enable or false;
      };
  };

  config = lib.mkIf (cfg.enable && config.personal.gui.enable) {
    xsession.enable = true;
    services = {
      picom.enable = lib.mkDefault true;
      network-manager-applet.enable = extraArgs.osConfig.networking.networkmanager.enable or false;
    };
  };
}
