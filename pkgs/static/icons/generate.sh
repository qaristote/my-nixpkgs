icons=$(cat urls.txt)

echo '{ fetchurl }:' | tee default.nix
echo '{' | tee -a default.nix
while read -r line; do
    name=$(echo $line | cut -f1 -d' ')
    url=$(echo $line | cut -f2 -d' ')
    sha256=$(nix-prefetch-url $url 2>/dev/null)
    echo -e "\t${name} = fetchurl {\n\t\turl = \"$url\";\n\t\tsha256 = \"$sha256\";\n\t};" | tee -a default.nix
done <<< $icons
echo '}' | tee -a default.nix

