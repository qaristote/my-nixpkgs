{
  config,
  lib,
  pkgs,
  ...
}@extraArgs:
let
  primaryEmail =
    let
      primaryEmailList = builtins.filter (account: account.primary) (
        lib.attrValues config.accounts.email.accounts
      );
    in
    if primaryEmailList == [ ] then
      {
        userName = lib.mkDefault "Quentin Aristote";
        address = lib.mkDefault "quentin@aristote.fr";
      }
    else
      builtins.head primaryEmailList;
in
{
  programs.git = {
    signing = lib.mkIf (primaryEmail ? "gpg") {
      inherit (primaryEmail.gpg) key signByDefault;
    };

    ignores = [
      (builtins.readFile (
        pkgs.personal.static.gitignore.override {
          templates = [
            "Emacs"
            "Linux"
          ];
        }
      ))
    ]
    ++ [
      # Personal rules
      ''
        # direnv
        .direnv
        .envrc

        # devenv
        .devenv.flake.nix
        .devenv/
        devenv.local.nix

        # Nix
        shell.nix
        .nix-gc-roots
        .tmp
        result
      ''
    ];

    settings = {
      user = {
        name = primaryEmail.userName;
        email = primaryEmail.address;
      };
      safe.directory = lib.mkIf (extraArgs ? osConfig) (
        let
          flake = extraArgs.osConfig.system.autoUpgrade.flake;
          flakeIsValid = flake != null && lib.hasPrefix "git+file://" flake;
          flakePath = lib.removePrefix "git+file://" flake;
        in
        lib.optional flakeIsValid flakePath
      );
      init.defaultBranch = "master";
      pull.rebase = true;
    };
  };

  programs.ssh.matchBlocks."git.aristote.fr" = {
    hostname = "hephaistos.aristote.mesh";
    user = "git";
    proxyJump = "sshjump@hermes.aristote.fr";
  };
}
