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
    "lulatex" = "4";
    "xelatex" = "5";
  };
  dviModes = {
    "latex" = "1";
    "lualatex" = "2";
  };
  latexmkrc = with latexmkrc; let
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
  in ''
    set_tex_cmds('${extraFlags}');
    $pdf_mode=${pdfMode}
    $dvi_mode=${dviMode}
    $ps_mode=${psMode}

    ${extraConfig}
  '';
  packages = cfg.packages cfg.base;
  packagesRequireShellEscape = packages ? minted;
  texlive = cfg.base.combine packages;
in {
  disabledModules = ["${devenv}/src/modules/languages/texlive.nix"];

  options.languages.texlive = {
    enable = lib.mkEnableOption "TeX Live";
    base = lib.mkPackageOption pkgs "TeX Live" {
      default = ["texlive"];
    };
    packages = lib.mkOption {
      type = with lib.types;
        functionTo (attrsOf (submodule {
          pkgs = lib.mkOption {
            type = listOf package;
          };
        }));
      default = tl: {inherit (tl) scheme-medium;};
      description = "Packages available to TeX Live.";
    };

    latexmk = {
      enable = lib.mkEnableOption "latexmk";
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

  config = lib.mkMerge [
    {
      languages.texlive = {
        latexmk = {
          shellEscape.enable = lib.mkIf (lib.mkDefault packagesRequireShellEscape true);
          extraFlags = lib.optional cfg.latexmkrc.shellEscape.enable "-shell-escape";
        };
        packages = tl: lib.optionalAttrs cfg.latexmk.enable {inherit (tl) latexmk;};
      };
      packages = lib.optional cfg.enable texlive;
    }
    (lib.mkIf cfg.latexmk.enable {
      scripts.latexmk.exec = ''
        ${texlive}/bin/latexmk -r ${devenv.root}/.latexmkrc
      '';
      dotfiles.".latexmkrc" = {
        gitignore = lib.mkDefault false;
        text = latexmkrc;
      };
    })
  ];
}
