{ config, lib, pkgs, ... }:

let cfg = config.programs.direnv;
in {
  programs.direnv.nix-direnv.enable = true;

  systemd.user = lib.mkIf cfg.enable
    (pkgs.personal.lib.homeManager.serviceWithTimer "direnv-clean-update" {
      Unit = {
        Description =
          "Remove old virtual environments and update the current ones";
        After = [ "network-online.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecSearchPath =
          "${pkgs.coreutils}/bin:${pkgs.findutils}/bin:${pkgs.direnv}/bin:/bin/sh";
        WorkingDirectory = "${config.home.homeDirectory}";
        ExecStart = ''
          find -type d -name .direnv \
               -execdir /bin/sh -c "rm -f .direnv/{nix,flake}-profile*" \; \
               -execdir direnv exec . true \;
        '';
      };
      Timer = {
        Persistent = true;
        OnCalendar = "daily";
      };
      Install = { WantedBy = [ "default.target " ]; };
    });
}
