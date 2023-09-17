devenvModules: {
  flake-parts-lib,
  inputs,
  ...
}: {
  imports = [inputs.devenv.flakeModule];

  options.perSystem = flake-parts-lib.mkPerSystemOption ({lib, ...}: {
    options.devenv.shells = lib.mkOption {
      type = with lib.types;
        lazyAttrsOf (submoduleWith {
          modules = builtins.attrValues devenvModules;
          shorthandOnlyDefinesConfig = null;
        });
    };
  });

  # the extra parameter before the module make this module behave like an
  # anonymous module, so we need to manually identify the file, for better
  # error messages, docs, and deduplication.
  _file = __curPos.file;
}
