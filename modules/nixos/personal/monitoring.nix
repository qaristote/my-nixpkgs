{
  config,
  lib,
  pkgs,
  ...
}: {
  options.systemd.services = lib.mkOption {
    type = with lib.types;
      attrsOf (submodule ({
        name,
        config,
        lib,
        ...
      }: {
        options.personal.monitor =
          lib.mkEnableOption "e-mail monitoring for the ${name} seervice";
        config.onFailure = lib.optional config.personal.monitor "notify@%i.service";
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

    systemd.services."notify@" = lib.mkDefault {
      description = "Send the status of the %i service as an e-mail.";
      serviceConfig.type = "oneshot";
      scriptArgs = "%i";
      script = let
        netCfg = config.networking;
        me = "${builtins.toString netCfg.hostName}.${builtins.toString netCfg.domain}";
      in ''
           service="$1"
        echo \
        "Subject: ${me}: service $service failed
        Service $service failed on ${me}, with the following status:

        $(systemctl status $service)
        " | ${pkgs.msmtp}/bin/msmtp quentin@aristote.fr
      '';
    };
  };
}
