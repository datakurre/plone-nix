# Requires .netrc file with
#
# machine repo.kopla.jyu.fi
# login username
# password secret

INDEX_URL ?= https://pypi.org/simple
INDEX_HOSTNAME ?=
PYPI_USERNAME ?=
PYPI_PASSWORD ?=

BUILDOUT_CFG ?= buildout.cfg
BUILDOUT_ARGS ?= -N

PYTHON ?= python37
NIX_OPTIONS ?= --pure --argstr python $(PYTHON)
REF_NIXPKGS = branches nixos-20.03

.netrc:
	@if [ -f ~/.netrc ]; then ln -s ~/.netrc .; else \
	  echo machine ${INDEX_HOSTNAME} > .netrc && \
	  echo login ${PYPI_USERNAME} >> .netrc && \
	  echo password ${PYPI_PASSWORD} >> .netrc; \
	fi

netrc: .netrc
	@ln -s .netrc netrc

.PHONY: requirements
requirements: requirements-$(PYTHON).nix

requirements-$(PYTHON).nix: requirements-$(PYTHON).txt requirements-manual.txt
	HOME=$(PWD) NIX_CONF_DIR=$(PWD) \
	nix-shell release.nix $(NIX_OPTIONS) -A pip2nix --run "HOME=$(PWD) NIX_CONF_DIR=$(PWD) pip2nix generate -r requirements-$(PYTHON).txt -r requirements-manual.txt --index-url $(INDEX_URL) --output=requirements-$(PYTHON).nix"

requirements-$(PYTHON).txt: requirements.txt
	HOME=$(PWD) NIX_CONF_DIR=$(PWD) \
	nix-shell release.nix $(NIX_OPTIONS) -A pip2nix --run "HOME=$(PWD) NIX_CONF_DIR=$(PWD) pip2nix generate -r requirements.txt --index-url $(INDEX_URL) --output=requirements-$(PYTHON).nix"
	@grep "pname =\|version =" requirements-$(PYTHON).nix|awk "ORS=NR%2?FS:RS"|sed 's|.*"\(.*\)";.*version = "\(.*\)".*|\1==\2|' > requirements-$(PYTHON).txt

requirements.txt: buildout.cfg
	nix-shell $(NIX_OPTIONS) --run "buildout -c $(BUILDOUT_CFG) $(BUILDOUT_ARGS)"

.PHONY: upgrade
upgrade:
	nix-shell --pure -p cacert curl gnumake jq nix --run "make release.nix"

.PHONY: release.nix
release.nix:
	@set -e pipefail; \
	echo "Updating nixpkgs @ setup.nix using $(REF_NIXPKGS)"; \
	rev=$$(curl https://api.github.com/repos/NixOS/nixpkgs-channels/$(firstword $(REF_NIXPKGS)) \
		| jq -er '.[]|select(.name == "$(lastword $(REF_NIXPKGS))").commit.sha'); \
	echo "Latest commit sha: $$rev"; \
	sha=$$(nix-prefetch-url --unpack https://github.com/NixOS/nixpkgs-channels/archive/$$rev.tar.gz); \
	sed -i \
		-e "2s|.*|    # $(REF_NIXPKGS)|" \
		-e "3s|.*|    url = \"https://github.com/NixOS/nixpkgs-channels/archive/$$rev.tar.gz\";|" \
		-e "4s|.*|    sha256 = \"$$sha\";|" \
		release.nix
