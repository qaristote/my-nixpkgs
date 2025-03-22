{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.personal.system;
  cfgRemote = cfg.autoUpgrade.remoteBuilding;
  cfgNix = config.nix;
  cfgLuks = config.boot.initrd.luks.devices;

  name = config.networking.hostName;
in {
  options.personal.system = {
    flake = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
    };
    autoUpgrade = {
      enable = lib.mkEnableOption "automatic system and nixpkgs upgrade";
      autoUpdateInputs = lib.mkOption {
        type = with lib.types; listOf str;
        default = ["nixpkgs" "my-nixpkgs/nur" "nixos-hardware"];
      };
      checkHosts = lib.mkOption {
        type = with lib.types; listOf str;
        default = with builtins; concatMap (match "https://([^/]*)/?") cfgNix.settings.substituters;
      };
      remoteBuilding = {
        enable = lib.mkEnableOption "remote building of the system configuration";
        builder = {
          hostName = lib.mkOption {
            type = lib.types.str;
            default = "hephaistos";
          };
          domain = lib.mkOption {type = lib.types.str;};
          user = lib.mkOption {
            type = lib.types.str;
            default = name;
          };
          protocol = lib.mkOption {
            type = lib.types.str;
            # Nix custom ssh-variant that avoids lots of "trusted-users" settings pain
            default = "ssh-ng";
          };
          speedFactor = lib.mkOption {
            type =
              lib.types.int;
            default = 8;
          };
        };
      };
    };
  };

  config = let
    hasFlake = cfg.flake != null;
    hasFlakeInputs = cfg.autoUpgrade.autoUpdateInputs != [];

    reboot = config.system.autoUpgrade.allowReboot;
    nixosRebuild = "nixos-rebuild ${toString config.system.autoUpgrade.flags}";

    remoteBuilder = with cfgRemote.builder; "${hostName}.${domain}";

    checkNetwork = {
      path = [pkgs.unixtools.ping];
      # Check network connectivity
      preStart = "(${lib.concatMapStringsSep " && " (host: "ping -c 1 ${host}") cfg.autoUpgrade.checkHosts}) || kill -s SIGUSR1 $$";
      unitConfig = {
        StartLimitIntervalSec = 300;
        StartLimitBurst = 5;
      };
      serviceConfig = {
        Restart = "on-abort";
        RestartSec = 30;
      };
    };
  in
    lib.mkMerge [
      (lib.mkIf hasFlake {
        system.autoUpgrade.flake = cfg.flake;
        systemd.services.flake-update = lib.mkIf hasFlakeInputs (lib.mkMerge [
          checkNetwork
          {
            description = "Update flake inputs";
            serviceConfig.Type = "oneshot";
            script = "nix flake update --commit-lock-file --flake ${cfg.flake} " + lib.concatStringsSep " " cfg.autoUpgrade.autoUpdateInputs;
            before = ["nixos-upgrade.service"];
            requiredBy = ["nixos-upgrade.service"];
            path = [pkgs.git cfgNix.package];
            personal.monitor = true;
          }
        ]);

        programs.git = lib.mkIf (lib.hasPrefix "git+file" cfg.flake) {
          enable = true;
          config.user = lib.mkDefault {
            name = "Root user of ${name}";
            email = "root@${name}";
          };
        };
      })

      (
        lib.mkIf (cfg.autoUpgrade.enable && cfgRemote.enable) {
          assertions = [
            {
              assertion = hasFlake && lib.hasPrefix "git+file://" cfg.flake;
              message = "Auto remote upgrade is only supported when the system is specified by a flake with path of the shape 'git+file://...'";
            }
          ];

          personal.system.autoUpgrade.checkHosts = lib.mkOptionDefault [remoteBuilder];

          programs.ssh = {
            extraConfig = ''
              Host ${remoteBuilder}
                IdentitiesOnly yes
                IdentityFile /etc/ssh/remoteBuilder
                User ${cfgRemote.builder.user}
            '';
            knownHosts."${remoteBuilder}".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHvtqi8tziBuviUV8LDK2ddQQUbHdJYB02dgWTK5Olxq";
          };
        }
      )

      (lib.mkIf cfg.autoUpgrade.enable {
        personal.boot.unattendedReboot = lib.mkIf reboot true;
        system.autoUpgrade = {
          enable = true;
          flags = lib.optional (!hasFlake) "--upgrade-all";
        };
        systemd.services.nixos-upgrade = lib.mkMerge [
          checkNetwork
          {
            path =
              lib.optional reboot pkgs.coreutils
              ++ [
                (
                  if cfgRemote.enable
                  then cfgNix.package
                  else pkgs.nixos-rebuild
                )
              ]
              ++ lib.optional (reboot && cfgLuks ? crypt) pkgs.cryptsetup;
            personal.monitor = true;
            script = lib.mkForce (lib.concatStrings [
              ''
                ## build configuration
              ''
              (
                let
                in
                  if cfgRemote.enable
                  then ''
                    # update remote flake
                    pushd ${lib.removePrefix "git+file://" cfg.flake}
                    git push --force ${cfgRemote.builder.hostName} master
                    popd
                    # build remotely
                    config=$(ssh ${remoteBuilder} -- \
                      'nix build --refresh --print-out-paths \
                         git+file://$(pwd)/nixos-configuration#nixosConfigurations.${name}.config.system.build.toplevel')
                    # copy result locally
                    nix-copy-closure --from ${remoteBuilder} "$config"
                    # create new generation
                    nix-env --profile /nix/var/nix/profiles/system \
                            --set "$config"

                    switch="$config/bin/switch-to-configuration"
                  ''
                  else ''
                    switch="${nixosRebuild}"
                  ''
              )
              ''
                ## check whether a reboot is necessary"
              ''
              (
                if reboot
                then ''
                  $switch boot
                  booted="$(readlink /run/booted-system/{initrd,kernel,kernel-modules})"
                  built="$(readlink /nix/var/nix/profiles/system/{initrd,kernel,kernel-modules})"
                  reboot="$([ "$booted" = "$built" ] || echo true)"
                ''
                else ''
                  reboot=""
                ''
              )
              ''
                ## switch to new configuration
              ''
              (let
                ifcrypt = lib.optionalString (cfgLuks ? crypt);
                crypt = cfgLuks.crypt.device;
                luksKey = x: "/etc/luks/keys/" + x;
              in ''
                if [ "$reboot" ]
                then
                  ${ifcrypt ''
                  cryptsetup luksAddKey ${crypt} ${luksKey "tmp"} \
                             --key-file ${luksKey "master"} \
                             --verbose
                ''}
                  shutdown -r now ${ifcrypt ''
                  || cryptsetup luksRemoveKey ${crypt} \
                                --key-file ${luksKey "tmp"} \
                                --verbose
                ''}
                else
                  $switch switch
                fi
              '')
            ]);
          }
        ];
      })
    ];
}
