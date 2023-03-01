{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  name = "material-design-icons-metadata";

  src = fetchFromGitHub {
    owner = "Templarian";
    repo = "MaterialDesign-Webfont";
    rev = "34bdb8135d3307eac87bcbd7377c5ae344f09b42";
    sha256 = "0mg6g262qjhjrkc9xjlv3s8a7qfh1wglfbg513d414xh3zlms4cl";
  };

  installPhase = ''
    mkdir -p $out
    cp --parent scss/_variables.scss $out
  '';
}
