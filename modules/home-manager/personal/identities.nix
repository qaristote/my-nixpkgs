{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.personal.identities;
  mkEnableIdentityOption = name: lib.mkEnableOption "${name} identity";
in
{
  options.personal.identities = {
    personal = mkEnableIdentityOption "personal";
    work = mkEnableIdentityOption "work";
  };

  config = lib.mkMerge [
    {
      accounts.email.accounts =
        let
          gpg = {
            key = "DFC1660846EEA97C059F18534EF515441E635D36";
            signByDefault = true;
          };
          thunderbirdSettings = id: {
            "mail.identity.id_${id}.fcc_folder_picker_mode" = 1;
          };
        in
        {
          personal = lib.mkIf cfg.personal {
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
              settings =
                id:
                thunderbirdSettings id
                // {
                  "mail.identity.id_${id}.draft_folder" =
                    "imap://quentin%40aristote.fr@ssl0.ovh.net/INBOX/Brouillons";
                  "mail.identity.id_${id}.fcc_folder" = "imap://quentin%40aristote.fr@ssl0.ovh.net/INBOX/Envoy&AOk-s";
                  "mail.identity.id_${id}.archive_folder" = "imap://quentin%40aristote.fr@ssl0.ovh.net/INBOX/Archive";
                  "mail.server.server_${id}.trash_folder_name" = "INBOX/Corbeille";
                };
            };
          };
          work = lib.mkIf cfg.work {
            inherit gpg;
            address = "quentin.aristote@irif.fr";
            userName = "aristote";
            realName = "Quentin Aristote";
            aliases = [ "aristote@irif.fr" ];
            folders = {
              drafts = "Drafts";
              inbox = "Inbox";
              sent = "Sent";
              trash = "Trash";
            };
            imap = {
              host = "imap.irif.fr";
              port = 143;
            };
            smtp = {
              host = "smtp.irif.fr";
              port = 587;
            };
            thunderbird = {
              enable = true;
              profiles = [ "default" ];
              settings =
                id:
                thunderbirdSettings id
                // {
                  "mail.identity.id_${id}.archive_folder" = "imap://aristote@imap.irif.fr/Archive";
                  "mail.server.server_${id}.trash_folder_name" = "Trash";
                };
            };
          };
        };
    }
    (lib.mkIf cfg.work {
      home = {
        packages =
          with pkgs;
          [
            zotero
            evince
          ]
          ++ lib.optional (!cfg.personal) zulip;
        file.".latexmkrc".source = lib.mkDefault config.personal.home.dotfiles.latexmkrc;
      };
      xdg.mimeApps.defaultApplications."application/pdf" = [ "org.gnome.Evince.desktop" ];
      programs.firefox.profiles =
        let
          addFloccus = {
            extensions.packages = [ pkgs.personal.firefoxAddons.floccus ];
          };
        in
        {
          default = addFloccus;
          videoconferencing = addFloccus;
        };
    })
  ];
}
