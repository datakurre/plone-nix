all: build

build: requirements.nix
	nix-build setup.nix -A env -o build

requirements.nix: requirements.txt
	nix-shell setup.nix -A pip2nix \
	  --run "pip2nix generate -r requirements-5.1.0.txt -r requirements.txt --output=requirements.nix"
