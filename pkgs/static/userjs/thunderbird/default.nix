{ fetchurl }:

let version = "102.2";
in fetchurl {
  url =
    "https://raw.githubusercontent.com/HorlogeSkynet/thunderbird-user.js/v${version}/user.js";
  sha256 = "b4cUbZ8aN4T0KwoHSijsRADt0egZZSnXNb1lY3KodKc=";
}
