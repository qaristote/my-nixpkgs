{
  lib,
  pkgs,
}:
let
  everyday = 24 * 60 * 60 * 1000;
  searchTerms = "{searchTerms}";
  nixosIcon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
  self = {
    disable =
      engines:
      lib.genAttrs engines (_: {
        metaData.hidden = true;
      });
    disableDefault = self.disable [
      "google"
      "Amazon.fr"
      "bing"
    ];

    nix = {
      inherit (self)
        "Home Manager Options"
        "NixOS Options"
        "NixOS Wiki"
        "Nix Packages"
        ;
    };
    dev = self.nix // {
      inherit (self) AlternativeTo Phind;
    };
    personal = { inherit (self) Emojipedia; };
    work = { inherit (self) nLab; };
    all = self.dev // self.personal // self.work // { inherit (self) Searx; };

    Emojipedia = {
      urls = [
        {
          template = "https://emojipedia.org/search/";
          params = [ (lib.nameValuePair "q" searchTerms) ];
        }
      ];
      icon = "https://emojipedia.org/static/img/favicons/favicon-16x16.png";
      updateInterval = everyday;
      definedAliases = [
        "@emojipedia"
        "@emoji"
        "@em"
      ];
    };

    AlternativeTo = {
      urls = [
        {
          template = "https://alternativeto.net/browse/search/";
          params = [ (lib.nameValuePair "q" searchTerms) ];
        }
      ];
      icon = "https://alternativeto.net/static/icons/a2/favicon-16x16.png";
      updateInterval = everyday;
      definedAliases = [
        "@alternativeto"
        "@a2"
      ];
    };

    "Home Manager Options" = {
      urls = [
        {
          template = "https://home-manager-options.extranix.com/?query={searchTerms}";
        }
      ];
      icon = nixosIcon;
      definedAliases = [
        "@homemanager"
        "@hm"
      ];
    };

    "NixOS Options" = {
      urls = [
        {
          template = "https://search.nixos.org/options";
          params = [
            (lib.nameValuePair "channel" "unstable")
            (lib.nameValuePair "query" searchTerms)
          ];
        }
      ];
      icon = nixosIcon;
      definedAliases = [
        "@nixos"
        "@no"
      ];
    };

    "NixOS Wiki" = {
      urls = [
        {
          template = "https://wiki.nixos.org/w/index.php";
          params = [ (lib.nameValuePair "search" searchTerms) ];
        }
      ];
      icon = nixosIcon;
      definedAliases = [
        "@nixoswiki"
        "@nw"
      ];
    };

    "Nix Packages" = {
      urls = [
        {
          template = "https://search.nixos.org/packages";
          params = [
            (lib.nameValuePair "channel" "unstable")
            (lib.nameValuePair "query" searchTerms)
          ];
        }
      ];
      icon = nixosIcon;
      definedAliases = [
        "@nixpkgs"
        "@np"
      ];
    };

    nLab = {
      urls = [
        {
          template = "https://ncatlab.org/nlab/search";
          params = [ (lib.nameValuePair "query" searchTerms) ];
        }
      ];
      icon = "https://ncatlab.org/favicon.ico";
      updateInterval = everyday;
      definedAliases = [
        "@ncatlab"
        "@nlab"
      ];
    };

    Searx = {
      urls = [
        {
          template = "https://searx.aristote.fr/search";
          params = [ (lib.nameValuePair "q" searchTerms) ];
        }
      ];
      icon = "https://searx.aristote.fr/static/themes/simple/img/favicon.svg";
      updateInterval = everyday;
    };

    Phind = {
      urls = [
        {
          template = "https://phind.com/search";
          params = [ (lib.nameValuePair "q" searchTerms) ];
        }
      ];
      icon = "https://www.phind.com/images/favicon.png";
      updateInterval = everyday;
      definedAliases = [
        "@phind"
        "@ph"
      ];
    };
  };
in
self
