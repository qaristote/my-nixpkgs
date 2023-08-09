{ config, lib, pkgs, ... }:

{
  options.systemd.services = lib.mkOption {
    type = with lib.types;
      attrsOf (submodule ({ name, ... }: {
        personal.monitor =
          lib.mkEnableOption "e-mail monitoring for the ${name} service";
      }));
  };

  config = {
    programs.msmtp = {
      enable = true;
      accounts.default = {
        auth = true;
        tls = true;
        tls_starttls = false;
        host = "ssl0.ovh.net";
        port = 465;
        from = "quentin-machines@aristote.fr";
        user = "quentin-machines@aristote.fr";
        passwordeval = "cat /etc/msmtp/secrets";
      };
    };

    systemd.services = lib.mkMerge [
      config.systemd.services
      {
        "notify@" = lib.mkDefault {
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
      }
      (builtins.mapAttrs (_: value: {
        onFailure = lib.optional value.personal.monitor "notify@%i.service";
      }) config.systemd.services)
    ];
  };
}
