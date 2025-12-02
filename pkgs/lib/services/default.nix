{ lib, pkgs }:

let
  checkNetwork =
    hosts:
    let
      pkg = pkgs.writeShellApplication {
        name = "check-network";
        runtimeInputs = [ pkgs.unixtools.ping ];
        text = ''
          for _ in {1..5}
          do
            (${lib.concatMapStringsSep " && " (host: "ping -c 1 ${host}") hosts}) && exit 0
            sleep 30
          done
          exit 1
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
      ...
    }:
    {
      # Check network connectivity
      Service = lib.mkMerge [
        {
          ExecStartPre = checkNetwork hosts;
        }
      ];
    };

  checkNetwork =
    {
      hosts,
      ...
    }:
    {
      # Check network connectivity
      preStart = checkNetwork hosts;
    };
}
