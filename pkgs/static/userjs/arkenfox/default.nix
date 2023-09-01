{fetchurl}: let
  version = "115.1";
in
  fetchurl {
    url = "https://raw.githubusercontent.com/arkenfox/user.js/${version}/user.js";
    sha256 = "sha256-pyJviSywIuDtM+yKVYLNn+TXCKmVI7au83SUVeGaHXQ=";
  }
