{
  config,
  lib,
  ...
}: let
  cfg = config.personal.boot;
in {
  options.personal.boot = {
    grub.enable = lib.mkEnableOption "grub";
    efi.enable = lib.mkEnableOption "EFI";
    unattendedReboot = lib.mkEnableOption "unattended reboots";
  };

  config.boot = {
    loader = lib.mkMerge [
      (lib.mkIf cfg.grub.enable {
        grub = {
          enable = true;
          enableCryptodisk = config.boot.initrd.luks.devices != {};
          device = lib.mkDefault "nodev";
        };
      })
      (lib.mkIf cfg.efi.enable {
        efi.canTouchEfiVariables = true;
        grub.efiSupport = true;
      })
    ];

    initrd = let
      crypt = config.personal.hardware.disks.crypted;
    in
      lib.mkIf (cfg.unattendedReboot && crypt != null) {
        secrets."/keyfile.luks" = /etc/luks/keys/tmp;
        luks.devices.crypt = {
          fallbackToPassword = true;
          keyFile = "/keyfile.luks";
          postOpenCommands = ''
            echo "Disabling temporary LUKS key file..."
            cryptsetup --verbose luksRemoveKey ${crypt} /keyfile.luks
          '';
        };
      };
  };
}
