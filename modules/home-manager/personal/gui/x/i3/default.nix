{ config, lib, pkgs, ... }@extraArgs:

let cfg = config.personal.x.i3;
in {
  imports = [ ./bar ./keybindings.nix ./startup.nix ];

  options.personal.x.i3 = {
    enable = lib.mkEnableOption "i3" // {
      default =
        extraArgs.osConfig.services.xserver.windowManager.i3.enable or false;
    };
  };

  config = lib.mkIf cfg.enable {
    xsession.windowManager.i3 = {
      enable = cfg.enable;
      package = lib.mkDefault pkgs.i3-gaps;

      config = {
        assigns = lib.optionalAttrs (config.personal.profiles.multimedia
          && (extraArgs.osConfig.programs.steam.enable or true)) {
            "8: multimedia" = [
              { class = "^Steam$"; }
              { class = "Netflix"; }
              { class = "MUBI"; }
              { class = "Deezer"; }
            ];
          } // lib.optionalAttrs config.personal.profiles.social {
            "9: social" = [ { class = "^Mail$"; } { class = "^thunderbird$"; } ]
              ++ lib.optional
              config.personal.identities.personal {
                class = "^signal-desktop$";
              };
          } // {
            "10: passwords" = [{
              # matches <some db>.kbdx [Locked] - KeePassXC
              title = ".*\\.kbdx \\[Locked\\] - KeePassXC$";
            }];
          };

        workspaceAutoBackAndForth = lib.mkDefault true;

        window = {
          titlebar = lib.mkDefault false;
          border = lib.mkDefault 0;
        };
        floating = {
          titlebar = lib.mkDefault false;
          border = lib.mkDefault (if config.services.picom.enable
          && config.services.picom.shadow then
            0
          else
            lib.mkOptionDefault);
        };
        gaps = {
          inner = lib.mkDefault 15;
          outer = lib.mkDefault 5;
        };
      };
    };
    programs.rofi.enable = lib.mkDefault true;
  };
}
