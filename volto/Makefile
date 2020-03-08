.PHONY: all
all: default.nix

default.nix: package-lock.json
	nix-shell -p nodePackages.node2nix --run "node2nix -l package-lock.json"
