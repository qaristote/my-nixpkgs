{
  config,
  lib,
  pkgs,
  options,
  ...
}: let
  cfg = config.personal.networking;
  mkFirewallEnableOption = name:
    lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to open ports for ${name}.";
    };
in {
  imports = [./wifi.nix];

  options.personal.networking = {
    enable = lib.mkEnableOption "networking";
    bluetooth.enable = lib.mkEnableOption "bluetooth";
    networkmanager.enable = lib.mkEnableOption "NetworkManager";
    ssh.enable = lib.mkEnableOption "SSH server";
    firewall = {
      syncthing = mkFirewallEnableOption "Syncthing";
      kdeconnect = mkFirewallEnableOption "KDE Connect";
      http = mkFirewallEnableOption "HTTP and HTTPS (incoming)";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      lib.optional cfg.networkmanager.enable pkgs.networkmanager;
    networking = {
      networkmanager = lib.mkIf cfg.networkmanager.enable {
        enable = true;
        unmanaged = ["interface-name:ve-*"];
      };
      firewall = {
        enable = true;
        allowedTCPPorts =
          lib.optional cfg.firewall.syncthing 22000
          ++ lib.optionals cfg.firewall.http [80 443];
        allowedUDPPorts = lib.optionals cfg.firewall.syncthing [22000 21027];
        allowedTCPPortRanges = lib.optional cfg.firewall.kdeconnect {
          from = 1714;
          to = 1764;
        };
        allowedUDPPortRanges = lib.optional cfg.firewall.kdeconnect {
          from = 1714;
          to = 1764;
        };
      };
    };
    services = lib.mkIf cfg.ssh.enable {
      openssh =
        {
          enable = true;
          extraConfig = ''
            AcceptEnv PS1
          '';
        }
        // (
          if options.services.openssh ? settings
          then {
            settings = {
              PermitRootLogin = "no";
              PasswordAuthentication = false;
            };
          }
          else {
            permitRootLogin = "no";
            passwordAuthentication = false;
          }
        );
      fail2ban = {
        enable = true;
        maxretry = 16;
        bantime-increment.enable = true;
      };
    };
    hardware.bluetooth.enable = cfg.bluetooth.enable;
  };
}
