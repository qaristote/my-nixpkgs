{...}: {
  imports = [
    ./boot.nix
    ./environment.nix
    ./gui.nix
    ./hardware.nix
    ./monitoring.nix
    ./networking
    ./nix.nix
    ./system.nix
    ./user.nix
  ];
}
