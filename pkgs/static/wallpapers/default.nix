{ stdenv, fetchurl, imagemagick, lib }:

let
  fetchWallpaper = lib.makeOverridable (
    { name, url, sha256, resolution ? "1920x1080", offset ? "0x0" }:
    stdenv.mkDerivation {
      inherit name;
      src = fetchurl {
        inherit url sha256;
      };
      buildInputs = [ imagemagick ];
      phases = [ "unpackPhase" ];
      unpackPhase = ''
        convert "$src" -resize "${resolution}^" \
                       -crop "${resolution}+${offset}" \
                "$out"
      '';
    });
  sources = lib.importJSON ./sources.json;
in {
  fetcher = fetchWallpaper;
} // builtins.mapAttrs (_: fetchWallpaper) sources
