{ fetchurl }:
{
  netflix = fetchurl {
    url = "https://www.vectorlogo.zone/logos/netflix/netflix-icon.svg";
    sha256 = "0i9211dsc8lrq8bvs9r217nwhfjcg84ja8b7lgqnza9ypv5lrqgs";
  };
  mubi = fetchurl {
    url = "https://mubi.com/MUBI-logo.png";
    sha256 = "0fc53c8j6dvphykabqiy146hjmpnczm5rvlf92fycyiqgrg260c4";
  };
  deezer = fetchurl {
    url = "https://raw.githubusercontent.com/edent/SuperTinyIcons/master/images/svg/deezer.svg";
    sha256 = "0gjh30082jc1yapkccp4fb9y2sr1q26gbqdjh0dkp9ldr00vy0q6";
  };
}
