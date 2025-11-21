{ lib, pkgs }:

let
  checkNetwork =
    hosts:
    let
      pkg = pkgs.writeShellApplication {
        name = "check-network";
        runtimeInputs = [ pkgs.unixtools.ping ];
        text = ''
          (${lib.concatMapStringsSep " && " (host: "ping -c 1 ${host}") hosts}) || kill -s SIGUSR1 $$
        '';
      };
    in
    "${pkg}/bin/check-network";
in
{
  home.serviceWithTimer =
    name:
    {
      Unit,
      Service,
      # Timer,
      Install,
      ...
    }@config:
    {
      services.${name} = { inherit (config) Unit Service; };
      timers.${name} = {
        inherit (config) Unit Install;
        Timer = config.Timer // {
          Unit = "${name}.service";
        };
      };
    };

  home.checkNetwork =
    {
      hosts,
      restart ? true,
    }:
    {
      # Check network connectivity
      Unit = {
        StartLimitIntervalSec = 300;
        StartLimitBurst = 5;
      };
      Service = lib.mkMerge [
        {
          ExecStartPre = checkNetwork hosts;
        }
        (lib.mkIf restart {
          Restart = "on-abort";
          RestartSec = 30;
          RestartMode = "direct"; # dependent units will not fail
        })
      ];
    };

  checkNetwork =
    {
      hosts,
      restart ? true,
    }:
    {
      # Check network connectivity
      preStart = checkNetwork hosts;
      unitConfig = {
        StartLimitIntervalSec = 300;
        StartLimitBurst = 5;
      };
      serviceConfig = lib.mkIf restart {
        Restart = "on-abort";
        RestartSec = 30;
        RestartMode = "direct"; # dependent units will not fail
      };
    };
}
