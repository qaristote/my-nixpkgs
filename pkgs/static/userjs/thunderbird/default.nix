{ fetchurl }:
let
  version = "140.2";
in
fetchurl {
  url = "https://raw.githubusercontent.com/HorlogeSkynet/thunderbird-user.js/v${version}/user.js";
  sha256 = "sha256-Y7TDCfp/sMDxotx2Mx9Idvi99vBGlMyCQ64EV6yGMCA=";
}
