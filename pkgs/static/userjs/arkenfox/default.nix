{fetchurl}: let
  version = "119.0";
in
  fetchurl {
    url = "https://raw.githubusercontent.com/arkenfox/user.js/${version}/user.js";
    sha256 = "sha256-q11lngXIypp3EEF2Cgz8t8pMhVYDMvdVSKs1aa7i52s=";
  }
