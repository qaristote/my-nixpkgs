{ fetchurl }:
let
  version = "140.1";
in
fetchurl {
  url = "https://raw.githubusercontent.com/arkenfox/user.js/${version}/user.js";
  sha256 = "sha256-jxzIiARi+GXD+GSGPr1exeEHjR/LsXSUQPGZ+hF36xg=";
}
