{ lib, pkgs, ... }:

{
  programs.git = {
    userName = lib.mkDefault "Quentin Aristote";
    userEmail = lib.mkDefault "quentin@aristote.fr";

    ignores = builtins.map builtins.readFile
      (with pkgs.personal; [ emacsGitignore linuxGitignore direnvGitignore ])
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
  };
}
