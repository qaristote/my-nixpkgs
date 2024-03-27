{...}: {
  imports = [
    ./boot.nix
    ./environment.nix
    ./gui.nix
    ./hardware.nix
    ./monitoring.nix
    ./networking
    ./nix.nix
    ./user.nix
  ];
}
