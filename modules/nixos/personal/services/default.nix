{ ... }:
{
  imports = [ ./nginx.nix ];

  systemd.services.tailscaled.personal.monitor = true;
}
