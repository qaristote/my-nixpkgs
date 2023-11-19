{fetchurl}: let
  version = "115.0";
in
  fetchurl {
    url = "https://raw.githubusercontent.com/HorlogeSkynet/thunderbird-user.js/v${version}/user.js";
    sha256 = "sha256-66B1yLQkQnydAUXD7KGt32OhWSYcdWX+BUozrgW9uAg=";
  }
