{ pkgs ? import <nixpkgs> {}
, pythonPackages ? pkgs.pythonPackages
, setup ? import (pkgs.fetchFromGitHub {
    owner = "datakurre";
    repo = "setup.nix";
    rev = "b1bfe61cd2f60f5446c8e3e74e99663fdbbaf7f6";
    sha256 = "1iw3ib6zwgyqnyr9gapsrmwprawws8k331cb600724ddv30xrpkg";
  })
}:

let
  overrides = import ./overrides.nix {
    inherit pkgs pythonPackages;
  };
  targets = setup {
    inherit pkgs pythonPackages overrides;
    src = ./.;
    force = true;
    propagatedBuildInputs = [ pkgs.gnupg ];
    image_name = "plone";
    image_entrypoint = "/bin/plonecli";
  };

in targets // {

  env = targets.env.override {
    postBuild = ''
      for path in $out/bin/*; do
        if [[ $path != *"/plonecli" &&
              $path != *"/gpg" ]]; then
           rm $path
        fi
      done
    '';
  };
}
