{
  templates ? [],
  toUncomment ? [],
  stdenvNoCC,
  fetchFromGitHub,
  lib,
}:
stdenvNoCC.mkDerivation {
  name = lib.concatStringsSep "+" templates + ".gitignore";
  version = "2023-06-30";

  src = fetchFromGitHub {
    owner = "toptal";
    repo = "gitignore";
    rev = "0a7fb01801c62ca53ab2dcd73ab96185e159e864";
    hash = "sha256-tZ+hlpt7T1by3f9BxzakjpQr+Y4top570J58q8VP9YE=";
  };

  buildPhase = ''
    cd templates
    for file in ${lib.concatStringsSep " " (builtins.map (name: lib.escapeShellArg "${name}.gitignore") templates)}
    do
      echo "### $(basename "$file" .gitignore)" >> $out
      cat "$file" >> $out
      echo >> $out
    done
    substituteInPlace $out ${lib.concatStringsSep " " (builtins.map (line: "--replace ${lib.escapeShellArg "# ${line}"} ${lib.escapeShellArg line}") toUncomment)}
  '';
}
