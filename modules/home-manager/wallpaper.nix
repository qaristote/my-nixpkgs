{ config, lib, ... }:

let wallpaper = config.personal.home.wallpaper;
in {
  options.personal.home.wallpaper = lib.mkOption {
    type = with lib.types; nullOr path;
    default = null;
    description = ''
      Path to the desktop wallpaper.
    '';
    example =
      lib.literalExample "${config.home.homeDirectory}/images/wallpaper.jpg";
  };
}
