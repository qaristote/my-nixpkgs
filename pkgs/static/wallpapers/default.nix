{
  stdenv,
  fetchurl,
  imagemagick,
  lib,
}: let
  fetchWallpaper = lib.makeOverridable (
    {
      name,
      url,
      sha256,
      resolution ? "1920x1080",
      ratio ? "16:9",
      gravity ? "center",
    }:
      stdenv.mkDerivation {
        inherit name;
        src = fetchurl {
          inherit url sha256;
        };
        buildInputs = [imagemagick];
        phases = ["unpackPhase"];
        unpackPhase = ''
          convert "$src" -gravity '${gravity}' \
                         -extent '${ratio}' \
                         -resize '${resolution}!' \
                  "$out"
        '';
      }
  );
  sources = lib.importJSON ./sources.json;
in
  {
    fetcher = fetchWallpaper;
  }
  // builtins.mapAttrs (_: fetchWallpaper) sources
