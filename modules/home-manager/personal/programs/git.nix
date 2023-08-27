{
  config,
  lib,
  pkgs,
  ...
} @ extraArgs: let
  primaryEmail = let
    primaryEmailList =
      builtins.filter (account: account.primary)
      (lib.attrValues config.accounts.email.accounts);
  in
    if primaryEmailList == []
    then {
      userName = lib.mkDefault "Quentin Aristote";
      address = lib.mkDefault "quentin@aristote.fr";
    }
    else builtins.head primaryEmailList;
in {
  programs.git = {
    userName = primaryEmail.userName;
    userEmail = primaryEmail.address;
    signing = lib.mkIf (primaryEmail ? "gpg") {
      inherit (primaryEmail.gpg) key signByDefault;
    };

    ignores =
      [
        (builtins.readFile
          (pkgs.personal.gitignore.override {templates = ["direnv" "Emacs" "Linux"];}))
      ]
      ++ [
        # Personal rules
        ''
          # Nix
          shell.nix
          .nix-gc-roots
          .tmp
          result
        ''
      ];

    extraConfig = {
      safe.directory = lib.mkIf (extraArgs ? osConfig) (
        let
          flake = extraArgs.osConfig.system.autoUpgrade.flake;
          flakeIsValid = flake != null && lib.hasPrefix "git+file://" flake;
          flakePath = lib.removePrefix "git+file://" flake;
        in
          lib.optional flakeIsValid flakePath
      );
    };
  };
}
