{ pkgs ? import <nixpkgs> {}
, release ? import ./release.nix {}
, var ? "$(PWD)"
}:

let
  instancehome = pkgs.stdenv.mkDerivation {
    name = "plone";
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      mkdir -p $out/etc
      cat > $out/etc/site.zcml << EOF
      <configure
          xmlns="http://namespaces.zope.org/zope"
          xmlns:meta="http://namespaces.zope.org/meta"
          xmlns:plone="http://namespaces.plone.org/plone"
          xmlns:five="http://namespaces.zope.org/five">

        <include package="Products.Five" />
        <meta:redefinePermission from="zope2.Public" to="zope.Public" />
        <meta:provides feature="disable-autoinclude" />

        <five:loadProducts file="meta.zcml"/>
        <five:loadProducts />
        <five:loadProductsOverrides />

        <include package="plonetheme.barceloneta" />
        <include package="plone.restapi" />

        <include package="plone.rest" file="meta.zcml" />
        <plone:CORSPolicy
          allow_origin="http://localhost:3000,http://127.0.0.1:3000,http://localhost:3001,http://127.0.0.1:3001"
          allow_methods="DELETE,GET,OPTIONS,PATCH,POST,PUT"
          allow_credentials="true"
          expose_headers="Content-Length,X-My-Header"
          allow_headers="Accept,Authorization,Content-Type,X-Custom-Header,Origin"
          max_age="3600"
          />

        <securityPolicy
            component="AccessControl.security.SecurityPolicy" />

    </configure>
    EOF
    '';
  };
  configuration = release.toZConfig {
    clienthome = "${var}";
    debug-mode = false;
    default-zpublisher-encoding = "utf-8";
    enable-product-installation = false;
    http-header-max-length = 8192;
    instancehome = "${instancehome}";
    lock-filename = "${var}/instance1.lock";
    pid-filename = "${var}/instance1.pid";
    python-check-interval = 1000;
    security-policy-implementation = "C";
    verbose-security = false;
    zserver-threads = 2;

    environment = {
      CHAMELEON_CACHE = "/tmp";
      PTS_LANGUAGES = [ "en" ];
      TMP = "/tmp";
      zope_i18n_allowed_languages = [ "en" ];
    };

    warnfilter = {
      action = "ignore";
      category = "DeprecationWarning";
    };

    eventlog = {
      level = "INFO";
      logfile = {
         path = "${var}/instance1.log";
         level = "INFO";
      };
    };

    logger = {
      access = {
        level = "WARN";
        logfile = {
          path = "${var}/instance1-Z2.log";
          format = "%(message)s";
        };
      };
    };

    http-server = {
      address = 8080;
      fast-listen = true;
    };

    zodb_db = {
      main = {
        cache-size = 40000;
        mount-point = "/";
        blobstorage = {
          blob-dir = "${var}/blostorage";
          filestorage = {
            path = "${var}/filestorage/Data.fs";
          };
        };
      };
      temporary = {
        temporarystorage = {
          name = "temporary storage for sessioning";
        };
        mount-point = "/temp_folder";
        container-class = "Products.TemporaryFolder.TemporaryContainer";
      };
    };
  };

in pkgs.stdenv.mkDerivation {
  name = "zope.conf";
  builder = builtins.toFile "builder.sh" ''
    source $stdenv/setup
    cat > $out << EOF
    $configuration
    EOF
  '';
  inherit configuration;
  propagatedBuildInputs = [ instancehome ];
}
