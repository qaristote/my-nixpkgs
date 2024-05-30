{
  config,
  lib,
  ...
} @ extraArgs: let
  cfg = config.personal.user;
  importedHomeManager = extraArgs ? home-manager;
in {
  imports =
    lib.optional importedHomeManager
    extraArgs.home-manager.nixosModules.home-manager;

  options.personal.user = {
    enable = lib.mkEnableOption "main user";
    name = lib.mkOption {
      type = lib.types.str;
      default = "qaristote";
    };
    homeManager = {enable = lib.mkEnableOption "home-manager";};
  };

  config = lib.mkIf cfg.enable ({
      users.users."${cfg.name}" = {
        isNormalUser = true;
        extraGroups =
          ["wheel"]
          ++ lib.optional config.sound.enable "sound"
          ++ lib.optional config.networking.networkmanager.enable
          "networkmanager";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK4wGbl3++lqCjLUhoRyABBrVEeNhIXYO4371srkRoyq qaristote@latitude-7490"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEvPsKWQXX/QsFQjJU0CjG4LllvUVZme45d9JeS/yhLt qaristote@precision-3571"
        ];
      };

      assertions = let
        missingArgAssertion = name: {
          assertion = lib.hasAttr name extraArgs || !cfg.homeManager.enable;
          message = "attribute ${name} missing: add it in lib.nixosSystem's specialArgs, or set config.personal.user.homeManager.enable to false";
        };
      in [
        (missingArgAssertion "homeModules")
        (missingArgAssertion "home-manager")
      ];
    }
    // lib.optionalAttrs (importedHomeManager && extraArgs ? homeModules) {
      home-manager = lib.mkIf cfg.homeManager.enable {
        users."${cfg.name}" = {
          imports = extraArgs.homeModules;
          stylix.targets.emacs.enable = false;
        };
        useGlobalPkgs = lib.mkDefault true;
        useUserPackages = lib.mkDefault true;
        # TODO fix this: only config.personal options seem to be passed (or not ?)
        extraSpecialArgs =
          (extraArgs.homeSpecialArgs or {})
          // {
            osConfig = lib.mkDefault config;
          };
      };
    });
}
