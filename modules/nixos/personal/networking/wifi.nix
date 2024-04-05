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
        id = "${id}";
        type = "wifi";
      };
      wifi = {
        inherit ssid;
        mode = "infrastructure";
      };
      wifi-security = {
        key-mgmt = "wpa-psk";
        # fill-in password on first connection
        # this will create a new connection
        # disable the personal.networking.wifi.enable option
        # to keep it for next rebuild
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
  knownSSIDs = {
    home = "Quentintranet";
    home-iot = "Quentinternet of Things";
    home-guest = "Quentinvités";
    aristote = "ARISTOTE";
    aristote-4g = "ARISTOTE 4G";
    stvictoret = "ORBIWAN";
    montlaur = "Nordnet_E080";
    montlaur-5g = "Nordnet_E080_5G";
  };
in {
  options.personal.networking.wifi = {
    enable = lib.mkEnableOption "personal WiFi networks";
    networks = lib.mkOption {
      type = with lib.types; listOf str;
      default = ["home-private" "hotspot"];
    };
    extraNetworks = lib.mkOption {
      type = with lib.types; listOf (attrsOf str);
      default = [];
      example = [
        {
          id = "my-wifi";
          ssid = "WiFi SSID";
        }
      ];
    };
  };

  config.networking.networkmanager.ensureProfiles.profiles = let
    networks =
      builtins.map (id: {
        inherit id;
        ssid =
          if lib.hasAttr id knownSSIDs
          then lib.getAttr id knownSSIDs
          else throw "Unknown WiFi ID: ${id}";
      })
      cfg.networks
      ++ cfg.extraNetworks;
    profiles = lib.mergeAttrsList (builtins.map mkWifiProfile networks);
  in
    lib.mkIf
    cfg.enable
    profiles;
}
