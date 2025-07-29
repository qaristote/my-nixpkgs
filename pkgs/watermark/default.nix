{
  writeShellApplication,
  coreutils,
  imagemagick,
  pdftk,
}:
writeShellApplication {
  name = "watermark";
  runtimeInputs = [
    coreutils
    imagemagick
    pdftk
  ];
  text = ''
    if [[ $1 == --help || $1 == -h ]]
    then
      echo "usage: watermark <receiver> <target> <output>"
      exit 0
    fi
    receiver="$1"
    target="$2"
    output="$3"
    dir=$(mktemp -d)
    pdftk "$target" burst output "$dir"/
    for page in "$dir"/*.pdf
    do
      magick -density 150 "$page" -flatten "$page".jpg
      magick -size 280x160 \
             xc:none \
             -fill '#50505050' \
             -pointsize 25 \
             -font Dejavu-Sans \
             -gravity NorthWest -draw "text 20,20 '$(date +%Y-%m-%d)'" \
             -gravity SouthEast -draw "text 10,30 '$receiver'" \
             miff:- \
        | magick composite -tile - "$page".jpg "$page".jpg
    done
    magick "$dir"/*.jpg "$output"
  '';
}
