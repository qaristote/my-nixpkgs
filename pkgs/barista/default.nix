{ buildGoModule, fetchFromGitHub, wirelesstools, fontawesomeMetadata, materialDesignIconsMetadata, i3statusGo ? null }:

let useDefaultConfig = i3statusGo == null;
in buildGoModule {
  name = "barista";
  version = "autorelease";

  src = fetchFromGitHub {
    owner = "soumya92";
    repo = "barista";
    rev = "ce8f4953e9ccf194b769f3d9ddb6806a1f7677d7";
    sha256 = "sha256-SzB4Zf9qW0ylob4iLTHR3tZpUl9Ns/F3gaUjuU+Ys1k=";
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

  vendorHash = "sha256-gpzxwtGxHcidRYY8o1Lz0iboU5aNnwsWfOoGo6Lvefo=";
}

