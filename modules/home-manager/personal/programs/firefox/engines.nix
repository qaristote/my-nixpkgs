{ lib, pkgs }:

let
  everyday = 24 * 60 * 60 * 1000;
  nixosIcon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
  self = {
    disable = engines: lib.genAttrs engines (name: { metaData.hidden = true; });
    disableDefault = self.disable [ "Google" "Amazon.fr" "Bing" ];

    nix = {
      inherit (self) "Home Manager Options" "NixOS Options" "NixOS Wiki" "Nix Packages";
    };
    dev = self.nix // { inherit (self) AlternativeTo; };
    personal = { inherit (self) Emojipedia; };
    work = { inherit (self) nLab; };
    all = self.dev // self.personal // self.work // { inherit (self) Searx; };

    Emojipedia = {
      urls = [{
        template = "https://emojipedia.org/search/";
        params = [ (lib.nameValuePair "q" "{searchTerms}") ];
      }];
      iconUpdateURL =
        "https://emojipedia.org/static/img/favicons/favicon-16x16.png";
      updateInterval = everyday;
      definedAliases = [ "@emojipedia" "@emoji" "@em" ];
    };

    AlternativeTo = {
      urls = [{
        template = "https://alternativeto.net/browse/search/";
        params = [ (lib.nameValuePair "q" "{searchTerms}") ];
      }];
      iconUpdateURL =
        "https://alternativeto.net/static/icons/a2/favicon-16x16.png";
      updateInterval = everyday;
      definedAliases = [ "@alternativeto" "@a2" ];
    };

    "Home Manager Options" = {
      urls = [{
        template =
          "https://mipmip.github.io/home-manager-option-search/?{searchTerms}";
      }];
      icon = nixosIcon;
      definedAliases = [ "@homemanager" "@hm" ];
    };

    "NixOS Options" = {
      urls = [{
        template = "https://search.nixos.org/options";
        params = [
          (lib.nameValuePair "channel" "unstable")
          (lib.nameValuePair "query" "{searchTerms}")
        ];
      }];
      icon = nixosIcon;
      definedAliases = [ "@nixos" "@no" ];
    };

    "NixOS Wiki" = {
      urls = [{
        template = "https://nixos.wiki/index.php";
        params = [ (lib.nameValuePair "search" "{searchTerms}") ];
      }];
      icon = nixosIcon;
      definedAliases = [ "@nixoswiki" "@nw" ];
    };

    "Nix Packages" = {
      urls = [{
        template = "https://search.nixos.org/packages";
        params = [
          (lib.nameValuePair "channel" "unstable")
          (lib.nameValuePair "query" "{searchTerms}")
        ];
      }];
      icon = nixosIcon;
      definedAliases = [ "@nixpkgs" "@np" ];
    };

    nLab = {
      urls = [{
        template = "https://ncatlab.org/nlab/search";
        params = [ (lib.nameValuePair "query" "{searchTerms}") ];
      }];
      iconUpdateURL = "https://ncatlab.org/favicon.ico";
      updateInterval = everyday;
      definedAliases = [ "@ncatlab" "@nlab" ];
    };

    Searx = {
      urls = [{
        template = "https://searx.aristote.fr/search";
        params = [ (lib.nameValuePair "q" "{searchTerms}") ];
      }];
      iconUpdateURL =
        "https://searx.aristote.fr/static/themes/oscar/img/favicon.png";
      updateInterval = everyday;
    };
  };
in self
