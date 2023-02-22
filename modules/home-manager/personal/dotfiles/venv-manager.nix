{ config, lib, pkgs, ... }:

{
  direnv.enable = lib.mkDefault true;

  haskell = { spacemacs.enable = lib.mkDefault true; };

  latex = {
    packages = tl: {
      inherit (tl)
        scheme-basic # scheme
        koma-script ragged2e everysel footmisc # koma
      ;
    };
    latexmk = {
      enable = lib.mkDefault true;
      output.pdf.enable = lib.mkDefault true;
      rc =
        lib.optional (lib.pathExists ~/.config/latexmkrc) ~/.config/latexmkrc;
    };
  };

  nix.enable = lib.mkDefault true;

  ocaml.tuareg.enable = lib.mkDefault true;

  coq.coq = pkgs.coq_8_15;
  # pkgs.coq_8_15.override { buildIde = false; };

  why3 = {
    defaultEditor = "emacsclient -c";
    extraConfig = lib.optionalString config.coq.enable ''
      [prover]
      editor = ""
      name = "Coq"
      version = "8.15+rc1"
    '';
  };
}
