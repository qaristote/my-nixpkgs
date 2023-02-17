{ config, lib, ... }:

let cfg = config.personal.user;
in {
  options.personal.user = {
    enable = lib.mkEnableOption "main user";
    name = lib.mkOption {
      type = lib.types.str;
      default = "qaristote";
    };
  };

  config.users.users."${cfg.name}" = lib.mkIf cfg.enable {
    isNormalUser = true;
    extraGroups = [ "wheel" ] ++ lib.optional config.sound.enable "sound"
      ++ lib.optional config.networking.networkmanager.enable "networkmanager";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK4wGbl3++lqCjLUhoRyABBrVEeNhIXYO4371srkRoyq qaristote@latitude-7490"
    ];

  };
}
