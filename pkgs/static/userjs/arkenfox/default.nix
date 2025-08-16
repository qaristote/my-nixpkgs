{ fetchurl }:
let
  version = "140.0";
in
fetchurl {
  url = "https://raw.githubusercontent.com/arkenfox/user.js/${version}/user.js";
  sha256 = "sha256-/cz0dnQXKa3c/DqUTAEwBV0I9Tc3x6uzU6rtYijg3Zo=";
}
