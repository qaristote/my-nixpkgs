{ fetchurl }:

let version = "112.0";
in fetchurl {
  url =
    "https://raw.githubusercontent.com/arkenfox/user.js/${version}/user.js";
  sha256 = "sha256-ZJ3HyM00hG3aVpOnrcjc/D75WsRj6rpKVRmmC3vp/4k=";
}
