{
  templates ? [],
  toUncomment ? [],
  stdenvNoCC,
  fetchFromGitHub,
  lib,
}:
stdenvNoCC.mkDerivation {
  name = lib.concatStringsSep "+" templates + ".gitignore";
  version = "2025-07-20";

  src = fetchFromGitHub {
    owner = "github";
    repo = "gitignore";
    rev = "9c2e50c7ccbf2f367f44e3c93e83934d12d67611";
    hash = "sha256-Zo0eOiCH6NWSjO1mm8KhoNDxQePb15dVKhxvQ62alyQ=";
  };

  buildPhase = ''
    mv {Global,community}/*.gitignore .
    for file in ${lib.concatStringsSep " " (builtins.map (name: lib.escapeShellArg "${name}.gitignore") templates)}
    do
      echo "### $(basename "$file" .gitignore)" >> $out
      cat "$file" >> $out
      echo >> $out
    done
    substituteInPlace $out ${lib.concatStringsSep " " (builtins.map (line: "--replace ${lib.escapeShellArg "# ${line}"} ${lib.escapeShellArg line}") toUncomment)}
  '';
}
