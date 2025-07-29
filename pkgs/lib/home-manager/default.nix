{ }:

{
  serviceWithTimer =
    name:
    {
      Unit,
      Service,
      Timer,
      Install,
      ...
    }@config:
    {
      services.${name} = { inherit (config) Unit Service; };
      timers.${name} = {
        inherit (config) Unit Install;
        Timer = config.Timer // {
          Unit = "${name}.service";
        };
      };
    };
}
