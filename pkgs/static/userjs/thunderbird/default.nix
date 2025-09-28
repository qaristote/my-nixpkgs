{ fetchurl }:
let
  version = "140.0";
in
fetchurl {
  url = "https://raw.githubusercontent.com/HorlogeSkynet/thunderbird-user.js/v${version}/user.js";
  sha256 = "sha256-y4OwHPPJUGBCID5FdfjygdnF/j4il/Ys8i7BbDyaPn8=";
}
