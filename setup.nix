{ pkgs ? import ((import <nixpkgs> {}).pkgs.fetchFromGitHub {
  owner = "NixOS";
  repo = "nixpkgs";
  rev = "4759056cf1290057845c7aa748c516be6a7e41d4";
  sha256 = "1169qavgxspnb74j30gkjbf1fxp46q96d97r56n69dmg35nfy2r9";
}) {}
, pythonPackages ? pkgs.pythonPackages
, setup ? import (pkgs.fetchFromGitHub {
    owner = "datakurre";
    repo = "setup.nix";
    rev = "b1bfe61cd2f60f5446c8e3e74e99663fdbbaf7f6";
    sha256 = "1iw3ib6zwgyqnyr9gapsrmwprawws8k331cb600724ddv30xrpkg";
  })
, overrides ? import ./overrides.nix { inherit pkgs pythonPackages; }
, src ? ./.
, image_name ? "plone"
, image_tag ? "latest"
}:

setup {
  inherit pkgs pythonPackages overrides src;
  force = true;
  inherit image_name image_tag;
  image_entrypoint = "/bin/plonecli";
}

## Note: By overriding ``env`` of the attribute set returned by setup, it is
## possible to limit available callable entrypoints in /bin of Docker image.
#
#  postBuild = ''
#     for path in $out/bin/*; do
#       if [[ $path != *"/plonecli" &&
#             $path != *"/gpg" ]]; then
#          rm $path
#       fi
#     done
#   '';
