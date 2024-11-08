{
  config,
  lib,
  pkgs,
  devenv,
  ...
}: let
  cfg = config.languages.texlive;
  pdfModes = {
    "pdflatex" = "1";
    "ps2pdf" = "2";
    "dvi2pdf" = "3";
    "lualatex" = "4";
    "xelatex" = "5";
  };
  dviModes = {
    "latex" = "1";
    "lualatex" = "2";
  };
  latexmkrc = with cfg.latexmk; let
    pdfMode = with output.pdf;
      if enable
      then pdfModes."${mode}"
      else "0";
    dviMode = with output.dvi;
      if enable
      then dviModes."${mode}"
      else "0";
    psMode =
      if output.ps.enable
      then "1"
      else "0";
  in
    lib.optionalString (extraFlags != []) ''
      set_tex_cmds('${lib.concatStringsSep " " extraFlags}');
    ''
    + ''
      $pdf_mode = ${pdfMode};
      $dvi_mode = ${dviMode};
      $ps_mode = ${psMode};

      $clean_ext = '${builtins.concatStringsSep " " cfg.latexmk.cleanExt}';
      $clean_full_ext = '${builtins.concatStringsSep " " cfg.latexmk.cleanFullExt}';

      ${extraConfig}
    '';
  packages = cfg.packages cfg.base;
  packagesRequireShellEscape = packages ? minted;
  texlive = cfg.base.combine packages;
in {
  disabledModules = [(devenv.modules + "/languages/texlive.nix")];

  options.languages.texlive = {
    enable = lib.mkEnableOption "TeX Live";
    base = lib.mkOption {
      default = pkgs.texlive;
      description = "TeX Live package set to use";
    };
    packages = lib.mkOption {
      type = with lib.types;
        functionTo (attrsOf (submodule {
          options.pkgs = lib.mkOption {
            type = listOf (either package (attrsOf anything));
          };
        }));
      default = tl: {inherit (tl) scheme-medium;};
      description = "Packages available to TeX Live.";
    };

    latexmk = {
      enable = lib.mkEnableOption "latexmk";
      cleanExt = lib.mkOption {
        type = with lib.types; listOf str;
        default = ["fdb_latexmk" "nav" "prv_%R.fmt" "prv_%R.log" "prv/*/*" "prv/*" "prv" "-SAVE-ERROR" "snm" "vrb"];
      };
      cleanFullExt = lib.mkOption {
        type = with lib.types; listOf str;
        default = ["bbl"];
      };
      shellEscape.enable = lib.mkEnableOption "shell escaping";
      extraFlags = lib.mkOption {
        type = with lib.types; listOf str;
        default = [];
        example = ["--interaction=nonstopmode"];
      };
      output = let
        mkOutputOptions = formats:
          lib.mapAttrs (format: extra:
            lib.recursiveUpdate {
              enable = lib.mkEnableOption "${format} output";
            }
            extra)
          formats;
      in
        mkOutputOptions {
          pdf = {
            enable.default = true;
            mode = lib.mkOption {
              type = lib.types.enum (lib.attrNames pdfModes);
              default = "lualatex";
              description = "How to generate the pdf file.";
            };
          };
          dvi = {
            mode = lib.mkOption {
              type = lib.types.enum (lib.attrNames dviModes);
              default = "latex";
              description = "How to generate the dvi file.";
            };
          };
          ps = {};
        };
      extraConfig = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = "Extra configuration to put inside the RC file.";
      };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      packages = [texlive];
      gitignore = {
        LaTeX.enable = true;
        extra = ''
          *-SAVE-ERROR
        '';
      };
    }
    (lib.mkIf cfg.latexmk.enable {
      languages.texlive = {
        packages = tl: {inherit (tl) latexmk;};
        latexmk = {
          shellEscape.enable = lib.mkDefault packagesRequireShellEscape;
          extraFlags = lib.optional cfg.latexmk.shellEscape.enable "-shell-escape";
        };
      };

      scripts.latexmk.exec = ''
        ${texlive}/bin/latexmk -r ${config.devenv.root}/.latexmkrc $@
      '';

      gitignore.LaTeX.uncomment = with cfg.latexmk.output; lib.optional pdf.enable "*.pdf" ++ lib.optional dvi.enable "*.dvi" ++ lib.optional ps.enable "*.ps";

      dotfiles.".latexmkrc" = {
        gitignore = lib.mkDefault false;
        text = latexmkrc;
      };
    })
  ]);
}
