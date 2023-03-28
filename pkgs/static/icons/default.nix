{ fetchurl }:
{
	netflix = fetchurl {
		url = "https://www.vectorlogo.zone/logos/netflix/netflix-icon.svg";
		sha256 = "0b4gqhw9y62fm72x61q03yzbllgfxpkjbbsdvj7d5wg3jshjkgdb";
	};
	mubi = fetchurl {
		url = "https://mubi.com/MUBI-logo.png";
		sha256 = "0fc53c8j6dvphykabqiy146hjmpnczm5rvlf92fycyiqgrg260c4";
	};
	deezer = fetchurl {
		url = "https://raw.githubusercontent.com/edent/SuperTinyIcons/master/images/svg/deezer.svg";
		sha256 = "1h9m9rsg3hdr7w5g8g560rlwyy2wmk5a397cg1vr7gg37v9izh92";
	};
}
