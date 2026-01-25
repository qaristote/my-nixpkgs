{ config, lib, ... }:
{
  services.nginx = {
    # recommended settings
    recommendedBrotliSettings = lib.mkDefault true;
    recommendedGzipSettings = lib.mkDefault true;
    recommendedOptimisation = lib.mkDefault true;
    recommendedProxySettings = lib.mkDefault true;
    recommendedTlsSettings = lib.mkDefault true;
    recommendedUwsgiSettings = lib.mkDefault config.services.uwsgi.enable;
  };
}
