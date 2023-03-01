{ fetchurl }:
{
	netflix = fetchurl {
		url = "https://www.vectorlogo.zone/logos/netflix/netflix-icon.svg";
		sha256 = "0b4gqhw9y62fm72x61q03yzbllgfxpkjbbsdvj7d5wg3jshjkgdb";
	};
	mubi = fetchurl {
		url = "https://mubi.com/logo";
		sha256 = "1h6qi579dcmd7l9mmwq2c4y67lbpkfjwq19kivfnfxwr38f769h4";
	};
	deezer = fetchurl {
		url = "https://raw.githubusercontent.com/edent/SuperTinyIcons/master/images/svg/deezer.svg";
		sha256 = "1qcj1gqz8gc9cwlj4cl6yj5ik1vz4ya6qcncr5fbciprzaaf3pg9";
	};
}
