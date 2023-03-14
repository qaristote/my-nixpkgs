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
      package = let emacs = config.programs.emacs.finalPackage; in
        pkgs.runCommand "emacsWrapped" {
          nativeBuildInputs = with pkgs; [ makeWrapper ];
        } ''
          mkdir "$out"
          ln -s ${emacs}/share "$out"
          for binary in ${emacs}/bin/*
          do
            makeWrapper "$binary" "$out"/bin/$(basename "$binary")\
                        --prefix PATH : ${lib.makeBinPath (with pkgs; [ gnutar gcc ])}
          done
          '';
    };
    home.sessionVariables.EDITOR = "emacsclient --tty";
    home.shellAliases.editor = "emacsclient --create-frame";

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
          ExecStart = "${spacemacs-update-script}/bin/spacemacs-update";
        };
        Timer = {
          Persistent = true;
          OnCalendar = "daily";
        };
        Install = { WantedBy = [ "default.target" ]; };
      });
  };
}
