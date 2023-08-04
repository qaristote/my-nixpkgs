{ config, lib, pkgs, ... }:

let cfg = config.personal.monitoring;
in {
  options.personal.monitoring = {
    enable = lib.mkEnableOption "e-mail monitoring";
    services = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ ];
      description = "The list of services whose failure should be notified.";
    };
  };

  config = {
    programs.msmtp = {
      enable = cfg.enable;
      accounts.default = {
        auth = true;
        tls = true;
        tls_starttls = false;
        host = "ssl0.ovh.net";
        port = 465;
        from = "quentin@aristote.fr";
        user = "quentin@aristote.fr";
        passwordeval = "cat /etc/msmtp/secrets";
      };
    };

    systemd.services = lib.mkIf cfg.enable (lib.mkMerge ([{
      "notify@" = {
        enable = true;
        description = "Send the status of the %i service as an e-mail.";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = let
            netCfg = config.networking;
            me = "${netCfg.hostName}.${netCfg.domain}";
            script = pkgs.writeScript "notify" ''
              #!${pkgs.runtimeShell}
              service="$1"
              echo \
              "Subject: ${me}: service $service failed
              Service $service failed on ${me}, with the following status:

              $(systemctl status $service)
              " | ${pkgs.msmtp}/bin/msmtp quentin@aristote.fr
            '';
          in "${script} %i";
        };
      };
    }] ++ builtins.map
      (service: { "${service}".onFailure = [ "notify@%i.service" ]; })
      cfg.services));
  };
}
