{ buildGoModule, fetchFromGitHub, wirelesstools, fontawesomeMetadata, materialDesignIconsMetadata, i3statusGo ? null }:

let useDefaultConfig = i3statusGo == null;
in buildGoModule {
  name = "barista";
  version = "autorelease";

  src = fetchFromGitHub {
    owner = "soumya92";
    repo = "barista";
    rev = "7ba8592f52325a15fe4971cd7800b9faf8638d17";
    sha256 = "Qd57ya/RBmkk8iMzYFCLVGIU0uTF4kP0JbQ5VZSwWH4=";
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

  vendorSha256 = "uE8/z5fJbgr2BTswQknVpXH7wcFNVkFNxEcVgzecfZo=";
}

