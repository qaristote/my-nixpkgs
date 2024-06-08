{fetchurl}: let
  version = "126.1";
in
  fetchurl {
    url = "https://raw.githubusercontent.com/arkenfox/user.js/${version}/user.js";
    sha256 = "1zh8sbx13n87jk0r6db8h9jp0lp9hz6lbyz5dnmcp1ya4b94c6sx";
  }
