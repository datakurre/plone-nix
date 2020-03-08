{ pkgs ? import (fetchTarball {
    # branches nixos-20.03
    url = "https://github.com/NixOS/nixpkgs-channels/archive/61cc1f0dc07c2f786e0acfd07444548486f4153b.tar.gz";
    sha256 = "1gvfl80vpb2wi4v5qnllfs8z0kzj6bmyk4aqxk6n0z2g41yxpf18";
  }) {}
, python ? "python37"
, pythonPackages ? builtins.getAttr (python + "Packages") pkgs
, requirements ?  ./. + "/requirements-${python}.nix"
}:

with builtins;
with pkgs;
with pkgs.lib;

let

  # Requirements for generating requirements.nix
  requirementsBuildInputs = [ cacert nix nix-prefetch-git
                              cyrus_sasl libffi libxml2 libxslt openldap ];
  buildoutPythonPackages = [ "cython" "pillow" "setuptools" ];

  # Load generated requirements
  requirementsFunc = import requirements {
    inherit pkgs;
    inherit (builtins) fetchurl;
    inherit (pkgs) fetchgit fetchhg;
  };

  # List package names in requirements
  requirementsNames = attrNames (requirementsFunc {} {});

  # Return base name from python drv name or name when not python drv
  pythonNameOrName = drv:
    if hasAttr "overridePythonAttrs" drv then drv.pname else drv.name;

  # Merge named input list from nixpkgs drv with input list from requirements drv
  mergedInputs = old: new: inputsName: self: super:
    (attrByPath [ inputsName ] [] new) ++ map
    (x: attrByPath [ (pythonNameOrName x) ] x self)
    (filter (x: !isNull x) (attrByPath [ inputsName ] [] old));

  # Merge package drv from nixpkgs drv with requirements drv
  mergedPackage = old: new: self: super:
    if isString new.src
       && !isNull (match ".*\.whl" new.src)  # do not merge build inputs for wheels
       && new.pname != "wheel"               # ...
    then new.overridePythonAttrs(old: rec {
      propagatedBuildInputs =
        mergedInputs old new "propagatedBuildInputs" self super;
    })
    else old.overridePythonAttrs(old: rec {
      inherit (new) pname version src;
      name = "${pname}-${version}";
      checkInputs =
        mergedInputs old new "checkInputs" self super;
      buildInputs =
        mergedInputs old new "buildInputs" self super;
      nativeBuildInputs =
        mergedInputs old new "nativeBuildInputs" self super;
      propagatedBuildInputs =
        mergedInputs old new "propagatedBuildInputs" self super;
      doCheck = false;
    });

  # Build python with manual aliases for naming differences between world and nix
  buildPython = (pythonPackages.python.override {
    packageOverrides = self: super:
      listToAttrs (map (name: {
        name = name; value = getAttr (getAttr name aliases) super;
      }) (filter (x: hasAttr (getAttr x aliases) super) (attrNames aliases)));
  });

  # Build target python with all generated & customized requirements
  targetPython = (buildPython.override {
    packageOverrides = self: super:
      # 1) Merge packages already in pythonPackages
      let super_ = (requirementsFunc self buildPython.pkgs);  # from requirements
          results = (listToAttrs (map (name: let new = getAttr name super_; in {
        inherit name;
        value = mergedPackage (getAttr name buildPython.pkgs) new self super_;
      })
      (filter (name: hasAttr "overridePythonAttrs"
                     (if (tryEval (attrByPath [ name ] {} buildPython.pkgs)).success
                      then (attrByPath [ name ] {} buildPython.pkgs) else {}))
       requirementsNames)))
      // # 2) with packages only in requirements or disabled in nixpkgs
      (listToAttrs (map (name: { inherit name; value = (getAttr name super_); })
      (filter (name: (! ((hasAttr name buildPython.pkgs) &&
                         (tryEval (getAttr name buildPython.pkgs)).success)))
       requirementsNames)));
      in # 3) finally, apply overrides (with aliased drvs mapped back)
      (let final = (super // (results //
        (listToAttrs (map (name: {
          name = getAttr name aliases; value = getAttr name results;
        }) (filter (x: hasAttr x results) (attrNames aliases))))
      )); in (final // (overrides self final)));
    self = buildPython;
  });

  # Alias packages with different names in requirements and in nixpkgs
  aliases = {
    "Pillow" = "pillow";
    "Pygments" = "pygments";
    "python-ldap" = "ldap";
  };

  # Final overrides to fix issues all the magic above cannot fix automatically
  overrides = self: super:

    # short circuit circulare dependency issues in Plone by ignoring dependencies
    super // (listToAttrs (map (name: {
      name = name;
      value = (getAttr name super).overridePythonAttrs(old: {
        pipInstallFlags = [ "--no-dependencies" ];
        propagatedBuildInputs = [];
        doCheck = false;
      });
    }) (filter (name: (! hasAttr name buildPython.pkgs)) requirementsNames)))
    // {

      # fix issues where the shortcut above breaks build
      "Automat" = super."Automat".overridePythonAttrs(old: {});
      "SecretStorage" = super."SecretStorage".overridePythonAttrs(old: {});
      "Twisted" = super."Twisted".overridePythonAttrs(old: {});
      "docutils" = super."docutils".overridePythonAttrs(old: {});
      "keyring" = super."keyring".overridePythonAttrs(old: {});
      "readme-renderer" = super."readme-renderer".overridePythonAttrs(old: {});
      "twine" = super."twine".overridePythonAttrs(old: {});

      # fix issue where nixpkgs drv is missing a dependency
      "sphinx" = super."sphinx".overridePythonAttrs(old: {
        propagatedBuildInputs = old.propagatedBuildInputs ++ [ self."packaging" ];
      });
    };

in rec {

  # shell with 'buildout' for resolving requirements.txt with buildout
  buildout = mkShell {
    buildInputs = requirementsBuildInputs ++ [
      (pythonPackages.python.withPackages(ps: with ps; [
        (zc_buildout_nix.overridePythonAttrs(old: { postInstall = ""; }))
      ] ++ map (name: getAttr name ps) buildoutPythonPackages))
    ];
  };

  # shell with 'pip2nix' for resolving requirements.txt into requirements.nix
  pip2nix = mkShell {
    buildInputs = requirementsBuildInputs ++ [
      (pythonPackages.python.withPackages(ps: with ps; [
        (zc_buildout_nix.overridePythonAttrs(old: { postInstall = ""; }))
        (getAttr
          ("python" + replaceStrings ["."] [""] pythonPackages.python.pythonVersion)
          ( import (fetchTarball {
              url = "https://github.com/datakurre/pip2nix/archive/7557e61808bfb5724ccae035d38d385a3c8d4dba.tar.gz";
              sha256 = "0rwxkbih5ml2mgz6lx23p3jgb6v0wvslyvscki1vv4hl3pd6jcld";
          } + "/release.nix") { inherit pkgs; }).pip2nix)
      ] ++ map (name: getAttr name ps) buildoutPythonPackages))
    ];
  };

  inherit buildPython targetPython toZConfig;

  # final env with packages in requirements.txt
  env = buildEnv {
    name = "plone-env";
    paths = [
      (targetPython.withPackages(ps: map (name: getAttr name ps) requirementsNames))
    ];
  };

  bin = stdenv.mkDerivation {
    name = "plone-bin";
    zope_conf = import ./zconfig/instance.nix {};
    plonesite_py = ./zconfig/plonesite.py;
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      mkdir -p $out/bin
      cat > $out/bin/plone-instance << EOF
      #!/usr/bin/env sh
      mkdir -p /var/plone/filestorage
      if [ ! -f /var/plone/.sentinel ]; then
          /bin/plonectl instance -C $zope_conf run $plonesite_py
          touch /var/plone/.sentinel
      fi
      /bin/plonectl instance -C $zope_conf console
      EOF
      chmod a+x $out/bin/plone-instance
    '';
  };

  volto = import ./volto/release.nix { inherit pkgs; };

  image = dockerTools.buildImage {
    name = "volto";
    tag = "latest";
    contents = [(buildEnv {
      name = "docker";
      paths = [ busybox curl env bin volto ];
    })];
    keepContentsDirlinks = true;
    runAsRoot = ''
      #!${stdenv.shell}
      ${dockerTools.shadowSetup}
      groupadd --system --gid 65534 nobody
      useradd --system --uid 65534 --gid 65534 -d / -s /sbin/nologin nobody
      echo "hosts: files dns" > /etc/nsswitch.conf
      mkdir -p /usr/bin && ln -s /sbin/env /usr/bin/env
      mkdir -p /tmp && chmod a+rxwt /tmp
      mkdir -p /var/plone/filestorage
      chown nobody:nobody -R /var/plone
    '';
    config = {
      EntryPoint = [ "/bin/plone-instance" ];
      Env = [
        "HOME=/var/plone"
        "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/ca-bundle.crt"
        "TMPDIR=/tmp"
      ];
      ExposedPots = {
        "8080/tcp" = {};
        "3000/tcp" = {};
      };
      Volumes = {
        "/var/plone" = {};
      };
      WorkingDir = "/var/plone";
      User = "nobody";
    };
  };

}
