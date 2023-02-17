pkgs:

let
  firefoxAddons = pkgs.callPackage ./firefox/addons { };
  gitignores = pkgs.callPackage ./gitignore { };
  icons = pkgs.callPackage ./icons { };
  personal =
    # lib
    {
      lib.home-manager = import ./lib/home-manager { };
    } //
    # firefox packages
    firefoxAddons // {
      arkenfoxUserJs = ./firefox/user-js/arkenfox.nix;
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
      filtron = pkgs.callPackage ./filtron {};
      lockscreen = pkgs.callPackage ./lockscreen { };
    } // gitignores // icons;
in personal
