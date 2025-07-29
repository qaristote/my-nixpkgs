{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.personal.home.lockscreen = lib.mkOption {
    type = lib.types.str;
    default = "${
      pkgs.personal.lockscreen.override {
        backgroundImage = config.personal.home.wallpaper;
      }
    }/bin/lockscreen.sh";
    description = ''
      Command to run for locking the screen.
    '';
  };
}
