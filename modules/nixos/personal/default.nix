{ lib, ... }:
{
  imports = [
    ./boot.nix
    ./environment.nix
    ./gui.nix
    ./hardware.nix
    ./monitoring.nix
    ./networking
    ./nix.nix
    ./services
    ./system.nix
    ./user.nix
  ];

  options.personal.lib.publicKeys.ssh = lib.mkOption {
    type = with lib.types; attrsOf str;
    default = { };
    example = {
      machine = "ssh-ed25519 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA user@domain";
    };
    description = "Known SSH public keys.";
  };

  config.personal.lib.publicKeys.ssh = {
    latitude-7490 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK4wGbl3++lqCjLUhoRyABBrVEeNhIXYO4371srkRoyq qaristote@latitude-7490";
    precision-3571 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEvPsKWQXX/QsFQjJU0CjG4LllvUVZme45d9JeS/yhLt qaristote@precision-3571";
    dragonfly-g4 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICT+jPcQhtBu4jxNAn54PV2TJ5krCfFnbXsR3OHk72l8 qaristote@dragonfly-g4";
    optiplex-9030 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDh2W0Nv76Nnw8TNysOkxVDZpnW0VEptq4u4Rask6zoO qaristote@optiplex-9030";
  };
}
