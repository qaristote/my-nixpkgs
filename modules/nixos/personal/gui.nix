{
  config,
  lib,
  pkgs,
  ...
} @ extraArgs: let
  cfg = config.personal.gui;
  wallpaper = pkgs.personal.static.wallpapers.nga-1973-68-1.override {gravity = "north";};
  importedStylix = extraArgs ? stylix;
in {
  imports = lib.optional importedStylix extraArgs.stylix.nixosModules.stylix;

  options.personal.gui = {
    enable = lib.mkEnableOption "GUI";
    xserver.enable = lib.mkEnableOption "X server";
    i3.enable = lib.mkEnableOption "i3";
    stylix.enable = lib.mkEnableOption "stylix";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      services.xserver = lib.mkIf cfg.xserver.enable {
        enable = true;
        desktopManager.xfce.enable = true;
        displayManager = {
          lightdm = {
            enable = true;
            background = config.stylix.image or wallpaper;
            greeters.gtk = {
              enable = true;
              extraConfig = ''
                user-background = false
              '';
              theme = lib.mkDefault {
                name = "Arc-Dark";
                package = pkgs.arc-theme;
              };
              iconTheme = lib.mkDefault {
                name = "Breeze-dark";
                package = pkgs.breeze-icons;
              };
            };
          };
        };
        # Hardware
        xkb.layout = config.personal.hardware.keyboard.keyMap;
        autoRepeatDelay = 200;
      };
    }
    # fragile conf
    (lib.mkIf cfg.i3.enable (
      lib.mkMerge [
        {
          services = {
            xserver = {
              desktopManager.xfce = {
                noDesktop = true;
                enableXfwm = false;
              };
              windowManager.i3.enable = true;
            };
          };
        }
        (
          let
            conf = {
              displayManager.defaultSession = "xfce+i3";
              libinput.enable = true;
            };
          in
            if (builtins.compareVersions lib.trivial.version "23.11" > 0)
            then {services = conf;}
            else {services.xserver = conf;}
        )
      ]
    ))
    (lib.mkIf cfg.stylix.enable ({
        assertions = let
          missingArgAssertion = name: {
            assertion = lib.hasAttr name extraArgs;
            message = "attribute ${name} missing: add it in lib.nixosSystem's specialArgs, or set config.personal.gui.stylix.enable to false";
          };
        in [(missingArgAssertion "stylix")];
      }
      // lib.optionalAttrs importedStylix {
        stylix = {
          enable = true;
          image = lib.mkDefault wallpaper;
          polarity = lib.mkDefault "dark";
          fonts.sizes = {
            applications = 10;
            desktop = 12;
          };
        };
      }))
  ]);
}
