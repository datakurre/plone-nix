{ pkgs ? import <nixpkgs> {}
, generators ? import ./generators.nix {}
, instancehome ? import ./instancehome.nix {}
, var ? "$(PWD)"
}:

let configuration = generators.toZConfig {

  effective-user = "nobody";
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
    PTS_LANGUAGES = [ "en" "fi" ];
    TMP = "/tmp";
    zope_i18n_allowed_languages = [ "en" "fi" ];
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
      zeoclient = {
        read-only = false;
        read-only-fallback = false;
        blob-dir = "${var}/blostorage";
        shared-blob-dir = true;
        server = "127.0.0.1:8660";
        storage = 1;
        name = "zeostorage";
        var = "${var}";
        cache-size = "128MB";
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
}; in

pkgs.stdenv.mkDerivation {
  name = "zope.conf";
  builder = builtins.toFile "builder.sh" ''
    source $stdenv/setup
    cat > $out << EOF
    $configuration
    EOF
  '';
  inherit configuration;
}
