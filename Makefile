.PHONY: all
all: build

.PHONY: build
build: requirements.nix
	nix-build setup.nix -A env -o build

requirements.nix: requirements.txt requirements-manual.txt
	@nix-shell -p libffi \
	--run 'nix-shell setup.nix -A pip2nix \
	--run "pip2nix generate -r requirements.txt -r requirements-manual.txt --output=requirements.nix"'

.PHONY: upgrade
upgrade:
	@echo "Updating nixpkgs unstable revision"; \
	rev=$$(curl https://api.github.com/repos/NixOS/nixpkgs-channels/branches/nixos-18.09|jq -r .commit.sha); \
	echo "Updating nixpkgs $$rev hash"; \
	sha=$$(nix-prefetch-url --unpack https://github.com/NixOS/nixpkgs-channels/archive/$$rev.tar.gz); \
	sed -i "2s|.*|    url = \"https://github.com/NixOS/nixpkgs-channels/archive/$$rev.tar.gz\";|" setup.nix; \
	sed -i "3s|.*|    sha256 = \"$$sha\";|" setup.nix; \
	echo "Updating setup.nix version"; \
	rev=$$(curl https://api.github.com/repos/datakurre/setup.nix/branches/master|jq -r ".commit.sha"); \
	echo "Updating setup.nix $$rev hash"; \
	sha=$$(nix-prefetch-url --unpack https://github.com/datakurre/setup.nix/archive/$$rev.tar.gz); \
	sed -i "6s|.*|    url = \"https://github.com/datakurre/setup.nix/archive/$$rev.tar.gz\";|" setup.nix; \
	sed -i "7s|.*|    sha256 = \"$$sha\";|" setup.nix
