{ config, lib, pkgs, ... }:

let cfg = config.personal.hardware;
in {
  options.personal.hardware = {
    usb.enable = lib.mkEnableOption "usb";
    disks.crypted = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      description = "Path to the encrypted disk.";
    };
    firmwareNonFree.enable = lib.mkEnableOption "non-free firmwares";
    keyboard = {
      keyMap = lib.mkOption {
        type = lib.types.str;
        default = "fr";
      };
    };
    backlights = let
      mkBacklightOption = name:
        lib.mkOption {
          type = with lib.types; nullOr str;
          default = null;
          description =
            "Whether to allow all users to change hardware the ${name} brightness.";
        };
    in {
      screen = mkBacklightOption "screen";
      keyboard = mkBacklightOption "keyboard";
    };
    sound.enable = lib.mkEnableOption "sound";
  };

  config = lib.mkMerge [
    {
      hardware.firmware =
        lib.optional cfg.firmwareNonFree.enable pkgs.firmwareLinuxNonfree;
      boot.initrd = {
        availableKernelModules = lib.optional cfg.usb.enable "usb_storage";
        luks.devices = lib.optionalAttrs (cfg.disks.crypted != null) {
          crypt = {
            name = "crypt";
            device = cfg.disks.crypted;
            preLVM = true;
          };
        };
      };

      services.udev.extraRules =
        lib.optionalString (cfg.backlights.screen != null) ''
          ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="${cfg.backlights.screen}", MODE="0666", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"
        '' + lib.optionalString (cfg.backlights.keyboard != null) ''
          ACTION=="add", SUBSYSTEM=="leds", KERNEL=="${cfg.backlights.keyboard}", MODE="0666", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/leds/%k/brightness"
        '';
    }

    (lib.mkIf cfg.sound.enable {
      sound.enable = true;
      hardware.pulseaudio = {
        enable = true;
        support32Bit = true;
        package = pkgs.pulseaudioFull;
        extraConfig = ''
          load-module module-dbus-protocol
        '';
      };
      nixpkgs.config.pulseaudio = true;
    })
  ];
}
