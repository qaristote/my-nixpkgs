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
          base16Scheme = lib.mkDefault {
            author = "Stylix";
            base00 = "212a27";
            base01 = "3a4a47";
            base02 = "596e73";
            base03 = "8ba0b5";
            base04 = "b0bbb7";
            base05 = "efe1be";
            base06 = "efefe5";
            base07 = "f1f1e5";
            base08 = "7e93a8";
            base09 = "92917f";
            base0A = "5d9c81";
            base0B = "859394";
            base0C = "8d9657";
            base0D = "b38861";
            base0E = "80977a";
            base0F = "a19052";
            scheme = "Stylix";
            slug = "stylix";
          };
          polarity = lib.mkDefault "dark";
          fonts.sizes = {
            applications = 10;
            desktop = 12;
          };
        };
      }))
  ]);
}
