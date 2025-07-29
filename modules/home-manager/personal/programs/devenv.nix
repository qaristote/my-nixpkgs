{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.personal.programs.devenv;
  importedDevenv = pkgs ? devenv;
  devenvUpdateScript = pkgs.callPackage (
    {
      bash,
      devenv,
      direnv,
      findutils,
      git,
      gnugrep,
    }:
    pkgs.writeShellApplication {
      name = "devenv-update";

      runtimeInputs = [
        bash
        devenv
        direnv
        findutils
        git
        gnugrep
      ];

      text = ''
        find . -name '.envrc' -execdir bash -c '
            if [[ $(direnv status | grep "Found RC allowed 0") ]]
            then
              echo Updating shell $(pwd)...
              devenv update
              devenv shell echo Shell $(pwd) updated!
              echo
            fi
          ' \;
      '';
    }
  ) { devenv = pkgs.devenv; };
in
{
  options.personal.programs.devenv.enable = lib.mkEnableOption "devenv";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = importedDevenv;
        message = "package devenv missing: add it in a nixpkgs overlay, or set config.personal.devenv.enable to false";
      }
    ];
    home.packages = lib.optional importedDevenv pkgs.devenv;

    systemd.user = pkgs.personal.lib.homeManager.serviceWithTimer "devenv-update" {
      Unit = {
        Description = "Update devenv shells";
        After = [
          "network-online.target"
        ];
      };
      Service = {
        Type = "oneshot";
        WorkingDirectory = "${config.home.homeDirectory}";
        ExecStart = "${devenvUpdateScript}/bin/devenv-update";
      };
      Timer = {
        Persistent = true;
        OnCalendar = "daily";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
