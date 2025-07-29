{ fetchurl }:
let
  version = "128.0";
in
fetchurl {
  url = "https://raw.githubusercontent.com/HorlogeSkynet/thunderbird-user.js/v${version}/user.js";
  sha256 = "sha256-V1cTcG52o24bF/0tki/c9+uOdpWaCxqZtIBoSqoQLYk=";
}
