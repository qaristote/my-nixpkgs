{ config, lib, pkgs, ... }:

let
  primaryEmail = let
    primaryEmailList = builtins.filter (account: account.primary)
      (lib.attrValues config.accounts.email.accounts);
  in if primaryEmailList == [ ] then {
    userName = lib.mkDefault "Quentin Aristote";
    address = lib.mkDefault "quentin@aristote.fr";
  } else
    builtins.head primaryEmailList;
in {
  programs.git = {
    userName = primaryEmail.userName;
    userEmail = primaryEmail.address;
    signing = lib.mkIf (primaryEmail ? "gpg") {
      inherit (primaryEmail.gpg) key signByDefault;
    };

    ignores = builtins.map builtins.readFile
      (with pkgs.personal.static.gitignore; [ direnv emacs linux ]) ++ [
        # Personal rules
        ''
          # Nix
          shell.nix
          .nix-gc-roots
          .tmp
          result
        ''
      ];
  };
}
