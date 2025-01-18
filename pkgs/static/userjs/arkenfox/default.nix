{fetchurl}: let
  version = "133.0";
in
  fetchurl {
    url = "https://raw.githubusercontent.com/arkenfox/user.js/${version}/user.js";
    sha256 = "sha256-rPcH24YqEBOzoPB9yxMlke/3tqpi9L7GVMsZ3MUP8WY=";
  }
