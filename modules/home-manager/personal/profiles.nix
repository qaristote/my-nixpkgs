{
  config,
  lib,
  pkgs,
  ...
}: let
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
      home.packages = with pkgs; [python3];
      programs = {
        alacritty.enable = lib.mkDefault config.personal.gui.enable;
        direnv.enable = lib.mkDefault true;
        emacs.enable = lib.mkDefault true;
        git.enable = lib.mkDefault true;
      };
      personal.programs.devenv.enable = true;

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

      services.gpg-agent.enableSshSupport = true;
    })

    (lib.mkIf cfg.multimedia {
      home.packages = with pkgs; [transmission-gtk vlc];
      personal = {
        gui.enable = lib.mkForce true;
        firefox.webapps = [
          {
            name = "Netflix";
            genericName = "Streaming service";
            icon = "${pkgs.personal.static.icons.netflix}";
            comment = "Unlimited movies, TV shows, and more.";
            url = "https://www.netflix.com/fr-en/login";
            categories = ["AudioVideo" "Video" "Player"];
          }
          {
            name = "MUBI";
            genericName = "Streaming service";
            icon = "${pkgs.personal.static.icons.mubi}";
            comment = "Watch hand-picked cinema.";
            url = "https://mubi.com";
            categories = ["AudioVideo" "Video" "Player"];
          }
          {
            name = "Deezer";
            genericName = "Streaming service";
            icon = "${pkgs.personal.static.icons.deezer}";
            comment = "Listen to music online";
            url = "https://deezer.com/login";
            categories = ["AudioVideo" "Audio" "Player" "Music"];
          }
        ];
      };
    })

    (lib.mkIf cfg.social {
      home.packages = with pkgs;
        lib.optionals
        (config.personal.gui.enable && config.personal.identities.personal)
        [signal-desktop];
      programs.thunderbird.enable = lib.mkDefault config.personal.gui.enable;
      programs.gpg.enable = true;
      services.gpg-agent.enable = true;
    })

    (lib.mkIf cfg.syncing {
      services = {
        kdeconnect.enable = lib.mkDefault true;
        syncthing.enable = lib.mkDefault true;
      };
    })
  ];
}
