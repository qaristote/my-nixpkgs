{
  config,
  lib,
  ...
}: let
  cfg = config.personal.networking.wifi;
  mkWifiProfile = {
    id,
    uuid,
    ssid,
  }: {
    "${id}" = {
      connection = {
        inherit id uuid;
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
          uuid = "e1e7e428-cf9f-4123-ac5b-641e6458d7e5";
        }
        {
          id = "hotspot";
          ssid = "Quentinternational";
          uuid = "e18bf2e0-e9b6-454c-b7f3-e264c29f4e88";
        }
        {
          id = "home-cercier";
          ssid = "ARISTOTE";
          uuid = "6ca53030-e03b-46ac-8a11-00b0787b3fa9";
        }
      ];
    };
  };

  config.networking.networkmanager.ensureProfiles.profiles = lib.mkIf cfg.enable (lib.mergeAttrsList (builtins.map mkWifiProfile cfg.networks));
}
