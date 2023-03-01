{ stdenv, fetchurl, fontsRelativeDirectory ? "./webfonts", fontDisplay ? "auto"
}:
stdenv.mkDerivation rec {
  name = "line-awesome.css";
  version = "v1.2.1";

  src = fetchurl {
    url =
      "https://raw.githubusercontent.com/icons8/line-awesome/${version}/dist/line-awesome/css/line-awesome.css";
    sha256 = "sha256:GU24Xz6l3Ww4ZCcL2ByssTe04fHBRz9k2aZVRdj0xm4=";
  };

  phases = [ "installPhase" ];
  installPhase = ''
    cp "$src" "$out"
    substituteInPlace "$out" --replace '../fonts' '${fontsRelativeDirectory}' \
                             --replace 'font-display: auto' 'font-display: ${fontDisplay}'
  '';
}
