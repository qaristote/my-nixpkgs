{ fetchurl, lib }:

let
  fetchGitignore = module: sha256:
    let
      url = "https://www.toptal.com/developers/gitignore/api/" + module;
      name = module + ".gitignore";
    in fetchurl { inherit url sha256 name; };
  sources = lib.importJSON ./sources.json;
in {
  fetcher = fetchGitignore;
} // builtins.mapAttrs fetchGitignore sources
