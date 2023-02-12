{ fetchurl }:

let
  fetch-gitignore = module: sha256:
    let url = "https://www.toptal.com/developers/gitignore/api/" + module;
        name = module + ".gitignore";
    in fetchurl { inherit url sha256 name; };
in {
  emacsGitignore = fetch-gitignore "emacs"
    "sha256:34LaJsGa5fFSMjE7l8JgQAmH8f07jcQmsaOdPVctHMk=";
  linuxGitignore = fetch-gitignore "linux"
    "sha256:Az39kpxJ1pG0T+3KUwx217+f+L8FQEWzwvRFSty8cJU=";
  direnvGitignore = fetch-gitignore "direnv"
    "sha256:CK47JLrsjf9yyjGAUfhjxLns0r1jDYgSBsp6LN0Yut8=";
  fetcherGitignore = fetch-gitignore;
}
