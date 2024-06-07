{fetchurl}: let
  version = "126.0";
in
  fetchurl {
    url = "https://raw.githubusercontent.com/arkenfox/user.js/${version}/user.js";
    sha256 = "0s5cp205ikics63xzbzws004vxi5bylz9jfakr7p9c6ip0cj2m64";
  }
