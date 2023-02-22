{ config, lib, pkgs, ... }:

let
  cfg = config.personal.profiles;
  mkEnableProfileOption = name: lib.mkEnableOption "${name} profile";
in {
  options.personal.profiles = {
    dev = mkEnableProfileOption "development";
    social = mkEnableProfileOption "social";
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

      services.gpg-agent = {
        enable = true;
        enableSshSupport = true;
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
            icon = "${pkgs.personal.netflixIcon}";
            comment = "Unlimited movies, TV shows, and more.";
            url = "https://www.netflix.com/fr-en/login";
            categories = [ "AudioVideo" "Video" "Player" ];
          }
          {
            name = "MUBI";
            genericName = "Streaming service";
            icon = "${pkgs.personal.mubiIcon}";
            comment = "Watch hand-picked cinema.";
            url = "https://mubi.com";
            categories = [ "AudioVideo" "Video" "Player" ];
          }
          {
            name = "Deezer";
            genericName = "Streaming service";
            icon = "${pkgs.personal.deezerIcon}";
            comment = "Listen to music online";
            url = "https://deezer.com/login";
            categories = [ "AudioVideo" "Audio" "Player" "Music" ];
          }
        ];
      };
    })

    (lib.mkIf cfg.social {
      home.packages = with pkgs;
        lib.optionals config.personal.gui.enable [ signal-desktop ];
      programs.thunderbird.enable = lib.mkDefault config.personal.gui.enable;
      accounts.email.accounts = let
        gpg = {
          key = "DFC1660846EEA97C059F18534EF515441E635D36";
          signByDefault = true;
        };
        thunderbirdSettings = id: {
          "mail.identity.id_${id}.fcc_folder_picker_mode" = 0;
        };
      in {
        personal = {
          inherit gpg;
          address = "quentin@aristote.fr";
          userName = "quentin@aristote.fr";
          realName = "Quentin Aristote";
          folders = {
            drafts = "Inbox/Brouillons";
            inbox = "Inbox";
            sent = "Inbox/Envoyés";
            trash = "Inbox/Corbeille";
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
            profiles = [ "all" "personal" ];
            settings = thunderbirdSettings;
          };
        };
        work = {
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
            profiles = [ "all" "work" ];
            settings = thunderbirdSettings;
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
