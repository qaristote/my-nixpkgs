{
  lib,
  stdenv,
  fetchurl,
  gtk2,
  pkg-config,
  hostname,
}:
stdenv.mkDerivation rec {
  pname = "rftg";
  version = "0.9.5";

  src = fetchurl {
    url = "https://github.com/bnordli/rftg/archive/refs/tags/${version}.tar.gz";
    sha256 = "sha256-y/LluUDpNr5Umxc/XPO2mMQWhZ50NxoDkZ7VYt0Sd18=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    gtk2.dev
    hostname
  ];

  preConfigure = ''
    cd src/
  '';

  installFlags = [ "prefix=$(out)" ];

  meta = {
    homepage = "http://keldon.net/rftg/";
    description = "Implementation of the card game Race for the Galaxy, including an AI";
    license = lib.licenses.gpl2Plus;
  };
}
