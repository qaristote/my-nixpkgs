{ fetchurl }:

let version = "110.0";
in fetchurl {
  url =
    "https://raw.githubusercontent.com/arkenfox/user.js/${version}/user.js";
  sha256 = "sha256:owhjLCesWzlTs9FAeDizZRPaYLdH3ksuklDHQWLgV6E=";
}
