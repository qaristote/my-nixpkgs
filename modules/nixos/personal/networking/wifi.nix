{
  config,
  lib,
  ...
}: let
  cfg = config.personal.networking.wifi;
  mkWifiProfile = {
    id,
    ssid,
  }: {
    "${id}" = {
      connection = {
        inherit id;
        type = "wifi";
      };
      wifi = {
        inherit ssid;
        mode = "infrastructure";
      };
      wifi-security = {
        key-mgmt = "wpa-psk";
        # fill-in password on first connection
      };
      ipv4 = {
        method = "auto";
      };
      ipv6 = {
        addr-gen-mode = "stable-privacy";
        method = "auto";
      };
      proxy = {
      };
    };
  };
in {
  options.personal.networking.wifi = {
    enable = lib.mkEnableOption "personal WiFi networks";
    networks = lib.mkOption {
      type = with lib.types; listOf (attrsOf str);
      default = [
        {
          id = "home-private";
          ssid = "Quentintranet";
        }
        {
          id = "hotspot";
          ssid = "Quentinternational";
        }
        {
          id = "home-cercier";
          ssid = "ARISTOTE";
        }
      ];
    };
  };

  config.networking.networkmanager.ensureProfiles.profiles = lib.mkIf cfg.enable (lib.mergeAttrsList (builtins.map mkWifiProfile cfg.networks));
}
