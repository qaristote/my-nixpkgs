pkgs:

let
  mozillaAddons = pkgs.callPackage ./mozilla/addons {
    inherit (pkgs.nur.repos.rycee.firefox-addons) buildFirefoxXpiAddon;
  };
  gitignores = pkgs.callPackage ./gitignore { };
  icons = pkgs.callPackage ./icons { };
  personal =
    # lib
    {
      lib = import ./lib { inherit (pkgs) lib; };
    } //
    # css
    {
      line-awesome-css = pkgs.callPackage ./css/lineAwesome { };
    } //
    # mozilla packages
    mozillaAddons // {
      arkenfoxUserJS = pkgs.callPackage ./mozilla/user-js/arkenfox.nix { };
      thunderbirdUserJS =
        pkgs.callPackage ./mozilla/user-js/thunderbird.nix { };
    } //
    # font metadata
    {
      fontawesomeMetadata = pkgs.callPackage ./fontMetadata/fontawesome.nix { };
      materialDesignIconsMetadata =
        pkgs.callPackage ./fontMetadata/materialDesignIcons.nix { };
    } //
    # miscellaneous
    {
      barista = pkgs.callPackage ./barista {
        inherit (personal) fontawesomeMetadata materialDesignIconsMetadata;
      };
      lockscreen = pkgs.callPackage ./lockscreen { };
    } // gitignores // icons;
in personal
