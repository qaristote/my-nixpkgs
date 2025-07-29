{ ... }:
{
  services = {
    safeeyes.enable = true;
    snixembed = {
      enable = true;
      beforeUnits = [ "safeeyes.service" ];
    };
  };
}
