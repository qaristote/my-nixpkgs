{fetchurl}: let
  version = "115.1";
in
  fetchurl {
    url = "https://raw.githubusercontent.com/arkenfox/user.js/${version}/user.js";
    sha256 = "sha256-sysEtq4aEWmkKy3KPe+4J/HJxjCxNcTAzptZ7s5JrJg=";
  }
