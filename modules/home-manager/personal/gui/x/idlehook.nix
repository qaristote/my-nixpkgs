{ config, lib, pkgs, ... }:

let
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
in {
  config.services.xidlehook = {
    enable = lib.mkDefault config.personal.x.enable;
    not-when-fullscreen = lib.mkDefault true;
    not-when-audio = lib.mkDefault true;
    timers = [
      {
        delay = 120;
        command = "${brightnessctl} set 10%-";
        canceller = "${brightnessctl} set +10%";
      }
      {
        delay = 180;
        command = config.personal.home.lockscreen;
      }
    ];
  };
}
