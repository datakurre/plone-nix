{ pkgs ? import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs-channels/archive/749a3a0d00b5d4cb3f039ea53e7d5efc23c296a2.tar.gz";
    sha256 = "14dqndpxa4b3d3xnzwknjda21mm3p0zmk8jbljv66viqj5plvgdw";
  }) {}
, setup ? import (fetchTarball {
    url = "https://github.com/datakurre/setup.nix/archive/9f8529e003ea4d2f433d2999dc50b8938548e7d0.tar.gz";
    sha256 = "15qzhz28jvgkna5zv7pj0gfnd0vcvafpckxcp850j64z7761apnm";
 })
, pythonPackages ? pkgs.python2Packages
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
