{ fetchurl }:

let version = "109.0";
in fetchurl {
  url =
    "https://raw.githubusercontent.com/arkenfox/user.js/${version}/user.js";
  sha256 = "sha256:+GJgFyfmFqbD3eepN9udJImT9H3Z9T+xnXPrHuSwIH4=";
}
