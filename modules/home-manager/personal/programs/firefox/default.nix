{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.personal.firefox;
  userjs = pkgs.callPackage ./userjs.nix {
    inherit (pkgs.personal.static.userjs) arkenfox;
    inherit (pkgs.lib.personal) toUserJS;
  };
  engines = import ./engines.nix {inherit lib pkgs;};
  userchrome = let
    userchromeTSTout = ./userchrome/treestyletabs-outer.css;
    userchromeTSTin = config.lib.stylix.colors {
      template = builtins.readFile ./userchrome/treestyletabs-inner.css;
      extension = ".css";
    };
  in
    ''
      @import "${userchromeTSTout}";
    ''
    + lib.optionalString (config.lib ? stylix) ''
      // @import "${userchromeTSTin}";
    '';
  webappsWithIds =
    (builtins.foldl' ({
        counter,
        value,
      }: {name, ...} @ next: {
        counter = counter + 1;
        value =
          value
          ++ [
            (next
              // {
                id = counter;
                profileName = lib.toLower name;
              })
          ];
      }) {
        counter = 0;
        value = [];
      }
      cfg.webapps)
    .value;
in {
  options.personal.firefox = {
    webapps = lib.mkOption {
      type = with lib.types;
        listOf (submodule {
          options = let
            mkTypedOption = type: lib.mkOption {inherit type;};
          in {
            name = mkTypedOption str;
            genericName = mkTypedOption str // {default = "";};
            url = mkTypedOption str;
            comment = mkTypedOption str // {default = "";};
            extraUserJS = mkTypedOption lines // {default = "";};
            categories = mkTypedOption (listOf str) // {default = [];};
            icon = mkTypedOption path;
          };
        });
      default = [];
    };
  };

  config = lib.mkMerge [
    {
      programs.firefox.profiles =
        builtins.foldl' (prev: {
          id,
          profileName,
          extraUserJS,
          ...
        }:
          prev
          // {
            "${profileName}" = {
              id = id + 2;
              extensions.packages = with pkgs.personal.firefoxAddons; [
                clearurls
                neat-url
                redirector
                smart-referer
                ublock-origin
                unpaywall
                url-in-title
              ];
              search = {
                force = true;
                engines = with engines; disableDefault // {inherit Searx;};
                default = "Searx";
                privateDefault = "Searx";
              };
              extraConfig = userjs.streaming + extraUserJS;
            };
          }) {
          default = {
            id = 0; # isDefault = true

            extensions.packages = with pkgs.personal.firefoxAddons; [
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
            search = {
              force = lib.mkDefault true;
              engines = with engines;
                disableDefault
                // {
                  inherit Searx;
                }
                // lib.optionalAttrs config.personal.identities.personal
                personal
                // lib.optionalAttrs config.personal.identities.work work
                // lib.optionalAttrs config.personal.profiles.dev dev;
              default = "Searx";
              order = ["Searx" "Wikipedia"];
            };
            extraConfig = userjs.default;
            userChrome = userchrome;
          };

          videoconferencing = {
            id = 1;
            extensions.packages = with pkgs.personal.firefoxAddons; [
              clearurls
              darkreader
              neat-url
              redirector
              smart-referer
              multi-account-containers
              tree-style-tab
              ublock-origin
              unpaywall
              url-in-title
            ];
            search = {
              force = true;
              engines = with engines; disableDefault // {inherit Searx;};
              default = "Searx";
            };
            extraConfig = userjs.videoconferencing;
            userChrome = userchrome;
          };
        }
        webappsWithIds;
    }

    (lib.mkIf config.programs.firefox.enable {
      xdg.desktopEntries = let
        firefoxProfilesDir = "${config.home.homeDirectory}/.mozilla/firefox";
        firefoxInProfile = profile: ''
          ${config.programs.firefox.package}/bin/firefox --profile "${firefoxProfilesDir}/${profile}"'';
      in
        builtins.foldl' (prev: {
          name,
          profileName,
          url,
          genericName,
          icon,
          comment,
          categories,
          ...
        }:
          prev
          // {
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
            categories = ["Network" "VideoConference"];
          };
        }
        webappsWithIds;

      home.shellAliases.fftmp = "firefox --profile $(mktemp -d)";
      home.sessionVariables.BROWSER = "firefox";
    })
  ];
}
