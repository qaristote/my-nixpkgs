{ config, lib, pkgs, ... }:

let
  cfg = config.programs.emacs;
  spacemacs-update-script = pkgs.callPackage ({ emacs, git }:
    pkgs.writeShellApplication {
      name = "spacemacs-update";

      runtimeInputs = [ emacs git ];

      text = ''
        git checkout develop
        git pull
        git checkout local
        git merge develop
        emacs --fg-daemon=update-daemon \
              --eval '(progn
                        (configuration-layer/update-packages "no-confirmation")
                        (spacemacs/kill-emacs))'
      '';
    }) { emacs = cfg.package; };
in {
  config = lib.mkIf cfg.enable {
    services.emacs = {
      enable = lib.mkDefault true;
      client.enable = lib.mkDefault true;
      startWithUserSession = lib.mkDefault true;
    };
    home.sessionVariables.EDITOR = "emacsclient --tty";

    # add some packages necessary in spacemacs
    programs.emacs.extraPackages =
      lib.mkDefault (ep: with ep; [ emacsql-sqlite emacsql-sqlite3 ]);
    home.packages = with pkgs; [ gnutar source-code-pro ];

    # spacemacs dotfile
    home.file.".spacemacs.d/init.el".source =
      lib.mkDefault config.personal.home.dotfiles.spacemacs;

    # service to update spacemacs
    systemd.user =
      (pkgs.personal.lib.homeManager.serviceWithTimer "spacemacs-update" {
        Unit = {
          Description = "Update Spacemacs by pulling the develop branch";
          After = [ "network-online.target" "emacs.service" ];
        };
        Service = {
          Type = "oneshot";
          WorkingDirectory = "${config.home.homeDirectory}/.emacs.d/";
          ExecStart = "${spacemacs-update-script}";
        };
        Timer = {
          Persistent = true;
          OnCalendar = "daily";
        };
        Install = { WantedBy = [ "default.target" ]; };
      });
  };
}
