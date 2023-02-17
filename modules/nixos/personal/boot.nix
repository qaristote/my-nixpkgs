{ config, lib, ... }:

let cfg = config.personal.boot;
in {
  options.personal.boot = {
    grub.enable = lib.mkEnableOption "grub";
    efi.enable = lib.mkEnableOption "EFI";
  };

  config.boot.loader = lib.mkMerge [
    (lib.mkIf cfg.grub.enable {
      grub = {
        enable = true;
        version = 2;
        enableCryptodisk = config.boot.initrd.luks.devices != { };
        device = lib.mkDefault "nodev";
      };
    })
    (lib.mkIf cfg.efi.enable {
      efi.canTouchEfiVariables = true;
      grub.efiSupport = true;
    })
  ];
}
