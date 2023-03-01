{ lib, ... }:

{
  services.picom = {
    fade = lib.mkDefault true;
    fadeDelta = lib.mkDefault 4;
    activeOpacity = lib.mkDefault 1.0;
    inactiveOpacity = lib.mkDefault 0.9;
    menuOpacity = lib.mkDefault 0.8;
    shadow = lib.mkDefault true;
    settings.blur.method = lib.mkDefault "gaussian";
    vSync = true; # not default because false seems to be buggy
    backend = "glx";
  };
}
