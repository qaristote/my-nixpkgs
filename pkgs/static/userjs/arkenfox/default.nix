{fetchurl}: let
  version = "118.0";
in
  fetchurl {
    url = "https://raw.githubusercontent.com/arkenfox/user.js/${version}/user.js";
    sha256 = "sha256-rWFgnARpraFfuuw6dkWlcoofct1PLFto5rqcbflgQPE=";
  }
