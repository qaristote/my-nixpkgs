{ lib }:

{
  homeManager = import ./home-manager { };
  toUserJS = prefs: ''
    ${lib.concatStrings (lib.mapAttrsToList (name: value: ''
      user_pref("${name}", ${builtins.toJSON value});
    '') prefs)}
  '';
}
