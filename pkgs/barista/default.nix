{ buildGoModule, fetchFromGitHub, wirelesstools, fontawesomeMetadata, materialDesignIconsMetadata, i3statusGo ? null }:

let useDefaultConfig = i3statusGo == null;
in buildGoModule {
  name = "barista";
  version = "autorelease";

  src = fetchFromGitHub {
    owner = "soumya92";
    repo = "barista";
    rev = "49c89827137e54835127183bf218bed1743e30a8";
    sha256 = "/GSiXgfTPJU2dJCZAUxiYknqsi/8loBQzzru02M2Ylg=";
  };

  patchPhase = ''
    mkdir main
  '' + (if useDefaultConfig then # use samples/i3status/i3status.go as config
  ''
    mv samples/i3status/i3status.go main/i3status.go
  '' else # import config and patch font loading
  ''
    cp ${i3statusGo} main/i3status.go
    substituteInPlace main/i3status.go \
                      --replace 'fontawesome.Load()' 'fontawesome.Load("${fontawesomeMetadata}")' \
                      --replace 'mdi.Load()' 'mdi.Load("${materialDesignIconsMetadata}")'
  '') + # patch call to iwgetid
    ''
      substituteInPlace modules/wlan/wlan.go \
                        --replace '/sbin/iwgetid' '${wirelesstools}/bin/iwgetid'
    '';

  subPackages = [ "main/i3status.go" ];

  vendorSha256 = "6dxBubWcBwS4+QX2Yi38GvTXgWxS00WemHmIbJI8JUQ=";
}

