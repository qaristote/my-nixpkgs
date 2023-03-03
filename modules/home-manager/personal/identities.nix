{ config, lib, pkgs, ... }:

let
  cfg = config.personal.identities;
  mkEnableIdentityOption = name: lib.mkEnableOption "${name} identity";
in {
  options.personal.identities = {
    personal = mkEnableIdentityOption "personal";
    work = mkEnableIdentityOption "work";
  };

  config = {
    accounts.email.accounts = let
      gpg = {
        key = "DFC1660846EEA97C059F18534EF515441E635D36";
        signByDefault = true;
      };
      thunderbirdSettings = id: {
        "mail.identity.id_${id}.fcc_folder_picker_mode" = 0;
      };
    in {
      personal = lib.mkIf config.personal.identities.personal {
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
              "mail.server.server_${id}.trash_folder_name" = "INBOX/Corbeille";
            };
        };
      };
      work = lib.mkIf config.personal.identities.work {
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
          settings = id:
            thunderbirdSettings id // {
              "mail.identity.id_${id}.archive_folder" =
                "imap://qaristote@clipper.ens.fr/Archive";
              "mail.server.server_${id}.trash_folder_name" = "Trash";
            };
        };
      };
    };

    home.packages = lib.optionals cfg.personal (with pkgs; [ ])
      ++ lib.optionals cfg.work (with pkgs; [ zotero ]);
  };
}
