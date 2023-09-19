{fetchurl}: let
  version = "117.0";
in
  fetchurl {
    url = "https://raw.githubusercontent.com/arkenfox/user.js/${version}/user.js";
    sha256 = "sha256-1z73xMZMmYzk7qnbsNdgO2tdrVfLVFK4zB2DfG5kxLY=";
  }
