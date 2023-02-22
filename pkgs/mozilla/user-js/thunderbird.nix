{ fetchurl }:

let version = "102.1";
in fetchurl {
  url =
    "https://raw.githubusercontent.com/HorlogeSkynet/thunderbird-user.js/v${version}/user.js";
  sha256 = "1zid28fjz86a82pg21xn7icxgbv7qqwrhy7nam4cp6d9jj16nr4x";
}
