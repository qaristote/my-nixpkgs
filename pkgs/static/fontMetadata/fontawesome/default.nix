{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "fontawesome-metadata";
  src = fetchFromGitHub {
    owner = "FortAwesome";
    repo = "Font-Awesome";
    rev = "d79d85c3fad85ad1885e87ed558f4afd6fce8289";
    sha256 = "1sqj64vmnpysy0mc4w7b393030dzlk2vn2i1a0bzi8zlbsrccm88";
  };

  installPhase = ''
    mkdir -p $out
    cp --parent metadata/icons.yml $out
  '';
}
