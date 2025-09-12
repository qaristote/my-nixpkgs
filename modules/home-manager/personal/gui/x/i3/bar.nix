{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.personal.x.i3;
  cfgStylix = config.stylix.targets.i3;
  mkDeviceOption = lib.mkOption {
    type = with lib.types; nullOr str;
    default = null;
  };
  ifDevice = device: attrs: lib.optional (device != null) ({ inherit device; } // attrs);
in
{
  options.personal.x.i3 = {
    devices = {
      wifi = mkDeviceOption;
      eth = mkDeviceOption;
      vpn = mkDeviceOption // {
        default = "tun0";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    xsession.windowManager.i3.config.bars = [
      {
        statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-default.toml";
        fonts = { inherit (cfgStylix.exportedBarConfig.fonts) size; };
      }
    ];

    programs.i3status-rust = {
      enable = true;
      bars = {
        default = {
          icons = "material-nf";
          blocks =
            (ifDevice cfg.devices.wifi {
              block = "net";
              device = cfg.devices.wifi;
              format = " ^icon_net_wireless  $ssid ";
            })
            ++ (ifDevice cfg.devices.eth {
              block = "net";
              device = cfg.devices.eth;
              format = " ^icon_net_wired {$ip|no IP address} ";
              inactive_format = " ^icon_net_wired × ";
              missing_format = " ^icon_net_wired × ";
            })
            ++ (ifDevice cfg.devices.vpn {
              block = "net";
              device = cfg.devices.vpn;
              format = " ^icon_net_vpn $ip ";
              inactive_format = " ^icon_net_vpn × ";
              missing_format = " ^icon_net_vpn × ";
            })
            ++ [
              {
                block = "disk_space";
                info_type = "used";
                path = "/";
                warning = 50.0;
                alert = 90.0;
                format = " $icon $percentage ";
              }
              (
                let
                  format = " $icon $percentage ";
                in
                {
                  block = "battery";
                  inherit format;
                  full_format = format;
                  charging_format = format;
                  empty_format = format;
                  not_charging_format = format;
                }
              )
              {
                block = "backlight";
              }
              {
                block = "sound";
                headphones_indicator = true;
                show_volume_when_muted = true;
              }
              {
                block = "sound";
                name = "@DEFAULT_SOURCE@";
                device_kind = "source";
                show_volume_when_muted = true;
              }
              {
                block = "time";
                interval = 1;
                format = " $timestamp.datetime(f:'%a. %b. %d, %H:%M:%S') ";
              }
            ];
        };
      };
    };
  };
}
