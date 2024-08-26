{fetchurl}: let
  version = "128.0";
in
  fetchurl {
    url = "https://raw.githubusercontent.com/arkenfox/user.js/${version}/user.js";
    sha256 = "sha256-CJk9sni0+cYC9rBHSL2mDQRtpsQJobQ1u3tq991Oi1c=";
  }
