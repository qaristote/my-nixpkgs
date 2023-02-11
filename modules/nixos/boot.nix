{ config, lib, ... }:

let cfg = config.personal.boot;
in {
  options.personal.boot = { grub.enable = lib.mkEnableOption "grub"; };

  config.boot.loader = lib.mkIf cfg.grub.enable {
    efi = { canTouchEfiVariables = true; };
    grub = {
      enable = true;
      version = 2;
      efiSupport = true;
      enableCryptodisk = config.boot.initrd.luks.devices != { };
      device = "nodev";
    };
  };
}
