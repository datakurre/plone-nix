{ python ? "python37"
}:

(import ./release.nix { inherit python; }).buildout
