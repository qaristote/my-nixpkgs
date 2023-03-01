{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.personal.firefox;
  userjs = pkgs.callPackage ./userjs.nix {
    inherit (pkgs.personal.static.userjs) arkenfox;
    inherit (pkgs.lib.personal) toUserJS;
  };
  engines = import ./engines.nix;
  userchrome-treestyletabs = ''
    /* Hide main tabs toolbar */
    #TabsToolbar {
      visibility: collapse;
    }
    /* Sidebar min and max width removal */
    #sidebar {
      max-width: none !important;
      min-width: 0px !important;
    }
    /* Hide sidebar header, when using Tree Style Tab. */
    #sidebar-box[sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"] #sidebar-header {
      visibility: collapse;
    }
  '';
  extensions = with pkgs.personal.firefoxAddons; [
    canvasblocker
    clearurls
    darkreader
    neat-url
    redirector
    smart-referer
    temporary-containers
    tree-style-tab
    ublock-origin
    unpaywall
    url-in-title
  ];
  webappsWithIds = (builtins.foldl' ({ counter, value }:
    { name, ... }@next: {
      counter = counter + 1;
      value = value ++ [
        (next // {
          id = counter;
          profileName = lib.toLower name;
        })
      ];
    }) {
      counter = 0;
      value = [ ];
    } cfg.webapps).value;
in {
  options.personal.firefox = {
    webapps = lib.mkOption {
      type = with lib.types;
        listOf (submodule {
          options = let mkTypedOption = type: lib.mkOption { inherit type; };
          in {
            name = mkTypedOption str;
            genericName = mkTypedOption str // { default = ""; };
            url = mkTypedOption str;
            comment = mkTypedOption str // { default = ""; };
            extraUserJS = mkTypedOption lines // { default = ""; };
            categories = mkTypedOption (listOf str) // { default = [ ]; };
            icon = mkTypedOption path;
          };
        });
      default = [ ];
    };
  };

  config = lib.mkMerge [
    {
      programs.firefox.profiles = builtins.foldl' (prev:
        { name, id, profileName, extraUserJS, ... }:
        prev // {
          "${profileName}" = {
            inherit extensions;
            id = id + 2;
            extraConfig = userjs.streaming + extraUserJS;
          };
        }) {
          default = {
            inherit extensions;
            id = 0; # isDefault = true

            extraConfig = userjs.default;
            userChrome = userchrome-treestyletabs;
            search = {
              force = lib.mkDefault true;
              engines = {
                inherit (engines) Searx;
                "Bing".metaData.hidden = true;
                "Google".metaData.hidden = true;
                "Amazon.fr".metaData.hidden = true;
              };
              default = "Searx";
              order = [ "Searx" "Wikipedia" ];
            };
          };

          videoconferencing = {
            inherit extensions;
            id = 1;

            extraConfig = userjs.videoconferencing;
            userChrome = userchrome-treestyletabs;
          };
        } webappsWithIds;
    }

    (lib.mkIf config.programs.firefox.enable {
      xdg.desktopEntries = let
        firefoxProfilesDir = "${config.home.homeDirectory}/.mozilla/firefox";
        firefoxInProfile = profile:
          ''
            ${config.programs.firefox.package}/bin/firefox --profile "${firefoxProfilesDir}/${profile}"'';
      in builtins.foldl' (prev:
        { name, profileName, url, genericName, icon, comment, categories, ... }:
        prev // {
          "${profileName}" = {
            inherit name genericName icon comment categories;
            exec = "${firefoxInProfile profileName} ${url}";
          };
        }) {
          videoconferences = {
            name = "Video Conferences";
            genericName = "Video conference";
            comment = "Use video conferencing software in a browser.";
            exec = "${firefoxInProfile "videoconferencing"}";
            categories = [ "Network" "VideoConference" ];
          };
        } webappsWithIds;

      home.shellAliases.fftmp = "firefox --profile $(mktemp -d)";
      home.sessionVariables.BROWSER = "firefox";
    })
  ];
}
