{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.filtron;
  addressType = lib.types.submodule {
    options = {
      address = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
      };
      port = lib.mkOption { type = lib.types.port; };
    };
  };
in
{
  options.services.filtron = {
    enable = lib.mkEnableOption "filtron";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.filtron;
      description = ''
        The package containing the filtron executable.
      '';
    };
    api = lib.mkOption {
      type = addressType;
      default = {
        address = "localhost";
        port = 4005;
      };
      description = ''
        API listen address and port.
      '';
    };
    listen = lib.mkOption {
      type = addressType;
      default = {
        port = 4004;
      };
      description = ''
        Proxy listen address and port.
      '';
    };
    target = lib.mkOption {
      type = addressType;
      default = {
        port = 8888;
      };
      description = ''
        Target address and port for reverse proxy.
      '';
    };
    rules = lib.mkOption {
      type = with lib.types; listOf (attrsOf anything);
      description = ''
        Rule list.
      '';
    };
    readBufferSize = lib.mkOption {
      type = lib.types.int;
      default = 16384;
      description = ''
        Size of the buffer used for reading.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.filtron = {
      description = "Filtron daemon user";
      group = "filtron";
      isSystemUser = true;
    };
    users.groups.filtron = { };

    systemd.services.filtron = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      description = "Start a filtron instance.";
      serviceConfig = {
        User = "filtron";
        ExecStart = with builtins; ''
          ${cfg.package}/bin/filtron \
                  -rules ${toFile "filtron-rules.json" (toJSON cfg.rules)} \
                  -api "${cfg.api.address}:${toString cfg.api.port}" \
                  -listen "${cfg.listen.address}:${toString cfg.listen.port}" \
                  -target "${cfg.target.address}:${toString cfg.target.port}" \
                  -read-buffer-size ${toString cfg.readBufferSize}
        '';
      };
    };
  };
}
