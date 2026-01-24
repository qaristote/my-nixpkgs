{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.rss-bridge;
in
{
  options.services.rss-bridge = {
    debug = lib.mkEnableOption "debug mode";
    extraBridges = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.strMatching "[a-zA-Z0-9]*";
              description = ''
                The name of the bridge.
                It need not include 'Bridge' at the end, unlike required in RSS-Bridge.
              '';
              example = "SomeAppWithANewsletter";
            };
            source = lib.mkOption {
              type = lib.types.path;
              description = ''
                The path to a file whose contents is the PHP sourcecode of the bridge.
                See also the RSS-Bridge documentation: https://rss-bridge.github.io/rss-bridge/Bridge_API/index.html.
              '';
            };
          };
        }
      );
      default = [ ];
      description = ''
        A list of additional bridges that aren't already included in RSS-Bridge.
        These bridges are automatically whitelisted'';
    };
  };

  config.services.rss-bridge.config.system.enabled_bridges = lib.mkIf cfg.enable (
    map (bridge: bridge.name) cfg.extraBridges
  );
  config.services.nginx = lib.mkIf (cfg.enable && cfg.virtualHost != null) {
    virtualHosts.${cfg.virtualHost}.root = lib.mkIf (cfg.extraBridges != [ ]) (
      lib.mkForce (
        pkgs.runCommand "rss-bridge" { } (
          ''
            mkdir -p $out/bridges
            cp -r ${cfg.package}/* $out/
            pushd $out/bridges
          ''
          + lib.concatStrings (
            map (bridge: ''
              ln -sf ${bridge.source} "${bridge.name}Bridge.php"
            '') cfg.extraBridges
          )
          + ''
            popd
          ''
          + lib.optionalString cfg.debug ''
            touch $out/DEBUG
          ''
        )
      )
    );
  };
}
