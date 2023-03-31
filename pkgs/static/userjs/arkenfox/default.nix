{ fetchurl }:

let version = "111.0";
in fetchurl {
  url =
    "https://raw.githubusercontent.com/arkenfox/user.js/${version}/user.js";
  sha256 = "sha256:HghuX+RftRVv1+XNwm2EC9JvKmGsuU4VWejdoo+dWmI=";
}
