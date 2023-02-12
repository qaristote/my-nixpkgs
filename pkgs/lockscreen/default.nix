{ runCommand, imagemagick, i3lock-color, lib, backgroundImage ? null, resolution ? "1920x1080" }:

let useBackgroundImage = backgroundImage != null;
in runCommand "lockscreen" { envVariable = true; } (''
  mkdir -p $out/{bin,share}
'' + (lib.optionalString useBackgroundImage ''
  ${imagemagick}/bin/convert ${backgroundImage} -resize ${resolution} -blur 0x5 RGB:$out/share/lockscreen.png
'') + ''
      echo > $out/bin/lockscreen.sh \
  	  "export PATH=$PATH
      ${i3lock-color}/bin/i3lock-color \\
      '' + (lib.optionalString useBackgroundImage ''
    --raw ${resolution}:rgb \\
    --image $out/share/lockscreen.png \\
  '') + ''
    --no-unlock-indicator \\
    --composite \\
    --clock \\
    --ignore-empty-password \\
    --time-color=FFFFFFFF \\
    --date-color=00000000 \\
    --time-size=100"
  '' + (lib.optionalString useBackgroundImage ''
    chmod 444 $out/share/lockscreen.png
  '') + ''
    chmod 555 $out/bin/lockscreen.sh
    chmod 555 $out/{bin,share}
  '')
