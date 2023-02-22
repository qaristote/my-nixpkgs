{ config, lib, ... }@extraArgs:

let cfg = config.personal.x;
in {
  imports = [ ./i3 ./idlehook.nix ];

  options.personal.x = {
    enable = lib.mkEnableOption "X" // {
      default = extraArgs.osConfig.services.xserver.enable or false;
    };
  };

  config.xsession.enable = lib.mkDefault cfg.enable;
}
