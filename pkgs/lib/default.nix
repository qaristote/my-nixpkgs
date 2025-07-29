{ lib }:

let
  self = {
    homeManager = import ./home-manager { };
    toUserJS = prefs: ''
      ${lib.concatStrings (
        lib.mapAttrsToList (name: value: ''
          user_pref("${name}", ${builtins.toJSON value});
        '') prefs
      )}
    '';
    updateInputFlag = input: [
      "--update-input"
      input
    ];
    updateInputFlags = inputs: builtins.concatLists (builtins.map self.updateInputFlag inputs);
  };
in
self
