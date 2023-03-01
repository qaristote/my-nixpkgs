super:

let
  self = {
    barista = super.callPackage ./barista {
      fontawesomeMetadata = self.static.fontMetadata.fontawesome;
      materialDesignIconsMetadata =
        self.static.fontMetadata.materialDesignIcons;
    };

    lib = import ./lib { inherit (super) lib; };

    lockscreen = super.callPackage ./lockscreen { };

    firefoxAddons = super.callPackage ./firefoxAddons {
      inherit (super.nur.repos.rycee.firefox-addons) buildFirefoxXpiAddon;
    };

    static = {
      css = { lineAwesome = super.callPackage ./static/css/lineAwesome { }; };
      fontMetadata = {
        fontawesome = super.callPackage ./static/fontMetadata/fontawesome { };
        materialDesignIcons =
          super.callPackage ./static/fontMetadata/materialDesignIcons { };
      };
      gitignore = super.callPackage ./static/gitignore { };
      icons = super.callPackage ./static/icons { };
      userjs = {
        arkenfox = super.callPackage ./static/userjs/arkenfox { };
        thunderbird = super.callPackage ./static/userjs/thunderbird { };
      };
      wallpapers = super.callPackage ./static/wallpapers { };
    };
  };
in self
