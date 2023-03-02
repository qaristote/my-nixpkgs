{ config, lib, pkgs, ... }:

let
  cfg = config.personal.profiles;
  mkEnableProfileOption = name: lib.mkEnableOption "${name} profile";
  mkEnableIdentityOption = name: lib.mkEnableOption "${name} identity";
in {
  options.personal.profiles = {
    dev = mkEnableProfileOption "development";
    social = {
      enable = mkEnableProfileOption "social";
      identities = {
        personal = mkEnableIdentityOption "personal";
        work = mkEnableIdentityOption "work";
      };
    };
    syncing = mkEnableProfileOption "syncing";
    multimedia = mkEnableProfileOption "video";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.dev {
      home.packages = with pkgs; [ gnupg python3 ];
      programs = {
        alacritty.enable = lib.mkDefault config.personal.gui.enable;
        direnv.enable = lib.mkDefault true;
        emacs.enable = lib.mkDefault true;
        git.enable = lib.mkDefault true;
      };

      home.shellAliases = {
        mkenv = ''
          cp ~/.config/venv-manager/shell-template.nix ./shell.nix ;
          echo "use_nix" >> .envrc ;
          direnv allow ;
          $EDITOR shell.nix ;
        '';
      };

      home.file = {
        ".config/latexmkrc".text =
          builtins.readFile config.personal.home.dotfiles.latexmkrc;
        ".config/venv-manager/config/default.nix".source =
          lib.mkDefault config.personal.home.dotfiles.venv-manager;
      };
    })

    (lib.mkIf cfg.multimedia {
      home.packages = with pkgs; [ pavucontrol transmission-gtk vlc ];
      personal = {
        gui.enable = lib.mkForce true;
        firefox.webapps = [
          {
            name = "Netflix";
            genericName = "Streaming service";
            icon = "${pkgs.personal.static.icons.netflix}";
            comment = "Unlimited movies, TV shows, and more.";
            url = "https://www.netflix.com/fr-en/login";
            categories = [ "AudioVideo" "Video" "Player" ];
          }
          {
            name = "MUBI";
            genericName = "Streaming service";
            icon = "${pkgs.personal.static.icons.mubi}";
            comment = "Watch hand-picked cinema.";
            url = "https://mubi.com";
            categories = [ "AudioVideo" "Video" "Player" ];
          }
          {
            name = "Deezer";
            genericName = "Streaming service";
            icon = "${pkgs.personal.static.icons.deezer}";
            comment = "Listen to music online";
            url = "https://deezer.com/login";
            categories = [ "AudioVideo" "Audio" "Player" "Music" ];
          }
        ];
      };
    })

    (lib.mkIf cfg.social.enable {
      home.packages = with pkgs;
        lib.optionals
        (config.personal.gui.enable && cfg.social.identities.personal)
        [ signal-desktop ];
      programs.thunderbird.enable = lib.mkDefault config.personal.gui.enable;
      services.gpg-agent = {
        enable = true;
        enableSshSupport = true;
      };

      accounts.email.accounts = let
        gpg = {
          key = "DFC1660846EEA97C059F18534EF515441E635D36";
          signByDefault = true;
        };
        thunderbirdSettings = id: {
          "mail.identity.id_${id}.fcc_folder_picker_mode" = 0;
        };
      in {
        personal = lib.mkIf cfg.social.identities.personal {
          inherit gpg;
          address = "quentin@aristote.fr";
          userName = "quentin@aristote.fr";
          realName = "Quentin Aristote";
          folders = {
            drafts = "INBOX/Brouillons";
            inbox = "INBOX";
            sent = "INBOX/Envoyés";
            trash = "INBOX/Corbeille";
          };
          imap = {
            host = "ssl0.ovh.net";
            port = 993;
          };
          smtp = {
            host = "ssl0.ovh.net";
            port = 465;
          };
          thunderbird = {
            enable = true;
            profiles = [ "default" ];
            settings = id:
              thunderbirdSettings id // {
                "mail.identity.id_${id}.draft_folder" =
                  "imap://quentin%40aristote.fr@ssl0.ovh.net/INBOX/Brouillons";
                "mail.identity.id_${id}.fcc_folder" =
                  "imap://quentin%40aristote.fr@ssl0.ovh.net/INBOX/Envoy&AOk-s";
                "mail.identity.id_${id}.archive_folder" =
                  "imap://quentin%40aristote.fr@ssl0.ovh.net/INBOX/Archive";
                "mail.server.server_${id}.trash_folder_name" =
                  "INBOX/Corbeille";
              };
          };
        };
        work = lib.mkIf cfg.social.identities.work {
          inherit gpg;
          address = "quentin.aristote@ens.fr";
          userName = "qaristote";
          realName = "Quentin Aristote";
          aliases = [
            "quentin.aristote@ens.psl.eu"
            "qaristote@clipper.ens.fr"
            "qaristote@clipper.ens.psl.eu"
          ];
          folders = {
            drafts = "Drafts";
            inbox = "Inbox";
            sent = "Sent";
            trash = "Trash";
          };
          imap = {
            host = "clipper.ens.fr";
            port = 993;
          };
          smtp = {
            host = "clipper.ens.fr";
            port = 465;
          };
          thunderbird = {
            enable = true;
            profiles = [ "default" ];
            settings = id: thunderbirdSettings id // {
                "mail.identity.id_${id}.archive_folder" =
                  "imap://qaristote@clipper.ens.fr/Archive";
                "mail.server.server_${id}.trash_folder_name" =
                  "Trash";
            };
          };
        };
      };
    })

    (lib.mkIf cfg.syncing {
      services = {
        kdeconnect.enable = lib.mkDefault true;
        syncthing.enable = lib.mkDefault true;
      };
    })
  ];
}
