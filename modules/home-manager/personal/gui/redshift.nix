{ config, lib, ... }@extraArgs:

{
  services.redshift = {
    enable = lib.mkDefault config.personal.gui.enable;
    tray = lib.mkDefault true;
    temperature = {
      day = lib.mkDefault 2500;
      night = lib.mkDefault 2500;
    };
    latitude = extraArgs.osConfig.location.latitude or (lib.mkDefault "48.856614");
    longitude = extraArgs.osConfig.location.longitude or (lib.mkDefault "2.3522219");
    settings.redshift.transition = lib.mkDefault 0;
  };
}
