{ pkgs, pythonPackages }:

self: super:  {
  Pillow = super.pillow;

  "eggtestinfo" = super.buildPythonPackage {
    name = "eggtestinfo-0.3";
    src = pkgs.fetchurl {
      url = "https://pypi.python.org/packages/e0/8e/77c064957ea14137407e29abd812160eafc41b73a377c30d9e22d76f14fd/eggtestinfo-0.3.tar.gz";
      sha256 = "0s77knsv8aglns4s98ib5fvharljcsya5clf02ciqzy5s794jjsg";
    };
    doCheck = false;
  };

  # https://github.com/plone/plonecli/archive/datakurre-zopectl.tar.gz
  "plonecli" = super."plonecli".overridePythonAttrs (old: {
    installFlags = [ "--no-deps" ];
    buildInputs = [ self."pytestrunner" ];
    src = pkgs.fetchFromGitHub {
      owner = "plone";
      repo = "plonecli";
      rev = "2070a22cb01c411fcff4e1354ccfc5bb68b4ef89";
      sha256 = "10izl11cz70lnn6ycq8rv32gqkgfnp5yvs300rgql5dlg3pz58w0";
    };
  });

  "jsonschema" = super."jsonschema".overridePythonAttrs (old: {
    buildInputs = [ self."vcversioner" ];
  });

  "piexif" = super."piexif".overridePythonAttrs (old: {
    buildInputs = [ pkgs."unzip" ];
  });

  "python-gettext" = super."python-gettext".overridePythonAttrs (old: {
    buildInputs = [ pkgs."unzip" ];
  });

  "pytz" = super."pytz".overridePythonAttrs (old: {
    buildInputs = [ pkgs."unzip" ];
  });

  "five.customerize" = super."five.customerize".overridePythonAttrs (old: {
    installFlags = [ "--no-deps" ];
    buildInputs = [ pkgs."unzip" ];
  });

  "repoze.xmliter" = super."repoze.xmliter".overridePythonAttrs (old: {
    buildInputs = [ pkgs."unzip" ];
  });

  "slimit" = super."slimit".overridePythonAttrs (old: {
    buildInputs = [ pkgs."unzip" ];
  });

  # https://github.com/zopefoundation/z3c.autoinclude/archive/pip.tar.gz
  "z3c.autoinclude" = super."z3c.autoinclude".overridePythonAttrs (old: {
    src = pkgs.fetchFromGitHub {
      owner = "zopefoundation";
      repo = "z3c.autoinclude";
      rev = "8f8c603024979a44b95a3fd104fff02cdb208da1";
      sha256 = "1mf11ivnyjdfmc2vdd01akqwqiss0q8ax624glxrzk8qx46spqqi";
    };
    installFlags = [ "--no-deps" ];
    propagatedBuildInputs = [];
  });

  "z3c.objpath" = super."z3c.objpath".overridePythonAttrs (old: {
    buildInputs = [ pkgs."unzip" ];
  });

  "z3c.pt" = super."z3c.pt".overridePythonAttrs (old: {
    installFlags = [ "--no-deps" ];
    buildInputs = [ pkgs."unzip" ];
  });

  "z3c.relationfield" = super."z3c.relationfield".overridePythonAttrs (old: {
    installFlags = [ "--no-deps" ];
    buildInputs = [ pkgs."unzip" ];
  });

  "zope.authentication" = super."zope.authentication".overridePythonAttrs (old: {
    installFlags = [ "--no-deps" ];
    buildInputs = [ pkgs."unzip" ];
  });

  "zope.broken" = super."zope.broken".overridePythonAttrs (old: {
    buildInputs = [ pkgs."unzip" ];
  });

  "zope.cachedescriptors" = super."zope.cachedescriptors".overridePythonAttrs (old: {
    buildInputs = [ pkgs."unzip" ];
  });

  "zope.configuration" = super."zope.configuration".overridePythonAttrs (old: {
    installFlags = [ "--no-deps" ];
    buildInputs = [ pkgs."unzip" ];
  });

  "zope.intid" = super."zope.intid".overridePythonAttrs (old: {
    installFlags = [ "--no-deps" ];
    buildInputs = [ pkgs."unzip" ];
  });

  "zope.app.publication" = super."zope.app.publication".overridePythonAttrs (old: {
    installFlags = [ "--no-deps" ];
    buildInputs = [ pkgs."unzip" ];
  });

  "zope.tal" = super."zope.tal".overridePythonAttrs (old: {
    buildInputs = [ pkgs."unzip" ];
  });

  "zope.untrustedpython" = super."zope.untrustedpython".overridePythonAttrs (old: {
    installFlags = [ "--no-deps" ];
    buildInputs = [ pkgs."unzip" ];
  });

  "virtualenv" = pythonPackages."virtualenv";

  "zope.security" = super."zope.security".overridePythonAttrs (old: {
    installFlags = [ "--no-deps" ];
    buildInputs = [ self."zope.interface" self."zope.proxy" ];
    propagatedBuildInputs = [];
  });

  "BTrees" = super."BTrees".overridePythonAttrs (old: {
    installFlags = [ "--no-deps" ];
    buildInputs = [ self."persistent" self."zope.interface" ];
    propagatedBuildInputs = [];
  });

  "Persistence" = super."Persistence".overridePythonAttrs (old: {
    installFlags = [ "--no-deps" ];
    buildInputs = [ pkgs."unzip" ];
  });

  "Products.Archetypes" = super."Products.Archetypes".overridePythonAttrs (old: {
    installFlags = [ "--no-deps" ];
    buildInputs = [ self."eggtestinfo" ];
    propagatedBuildInputs = [];
  });

  "Products.CMFCore" = super."Products.CMFCore".overridePythonAttrs (old: {
    installFlags = [ "--no-deps" ];
    buildInputs = [ self."eggtestinfo" ];
    propagatedBuildInputs = [];
  });

  "Products.CMFUid" = super."Products.CMFUid".overridePythonAttrs (old: {
    installFlags = [ "--no-deps" ];
    buildInputs = [ self."eggtestinfo" ];
    propagatedBuildInputs = [];
  });

  "Products.DateRecurringIndex" = super."Products.DateRecurringIndex".overridePythonAttrs (old: {
    installFlags = [ "--no-deps" ];
    buildInputs = [ pkgs."unzip" ];
  });

  "Products.DCWorkflow" = super."Products.DCWorkflow".overridePythonAttrs (old: {
    installFlags = [ "--no-deps" ];
    buildInputs = [ self."eggtestinfo" ];
    propagatedBuildInputs = [];
  });

  "Products.ExternalMethod" = super."Products.ExternalMethod".overridePythonAttrs (old: {
    installFlags = [ "--no-deps" ];
    buildInputs = [ pkgs."unzip" ];
  });

  "Products.GenericSetup" = super."Products.GenericSetup".overridePythonAttrs (old: {
    installFlags = [ "--no-deps" ];
    buildInputs = [ self."eggtestinfo" ];
    propagatedBuildInputs = [];
  });

  "Products.MailHost" = super."Products.MailHost".overridePythonAttrs (old: {
    installFlags = [ "--no-deps" ];
    buildInputs = [ pkgs."unzip" ];
  });

  "Products.MIMETools" = super."Products.MIMETools".overridePythonAttrs (old: {
    installFlags = [ "--no-deps" ];
    buildInputs = [ pkgs."unzip" ];
  });

  "Products.OFSP" = super."Products.OFSP".overridePythonAttrs (old: {
    installFlags = [ "--no-deps" ];
    buildInputs = [ pkgs."unzip" ];
  });

  "Products.PythonScripts" = super."Products.PythonScripts".overridePythonAttrs (old: {
    installFlags = [ "--no-deps" ];
    buildInputs = [ pkgs."unzip" ];
  });

  "RestrictedPython" = super."RestrictedPython".overridePythonAttrs (old: {
    buildInputs = [ pkgs."unzip" ];
  });

  "Products.Sessions" = super."Products.Sessions".overridePythonAttrs (old: {
    installFlags = [ "--no-deps" ];
    buildInputs = [ pkgs."unzip" ];
  });

  "Products.TemporaryFolder" = super."Products.TemporaryFolder".overridePythonAttrs (old: {
    installFlags = [ "--no-deps" ];
    buildInputs = [ pkgs."unzip" ];
  });

  "Products.ZCTextIndex" = super."Products.ZCTextIndex".overridePythonAttrs (old: {
    installFlags = [ "--no-deps" ];
    buildInputs = [ pkgs."unzip" ];
  });

  "Record" = super."Record".overridePythonAttrs (old: {
    buildInputs = [ pkgs."unzip" ];
  });

  "zExceptions" = super."zExceptions".overridePythonAttrs (old: {
    installFlags = [ "--no-deps" ];
    buildInputs = [ pkgs."unzip" ];
  });

  "zLOG" = super."zLOG".overridePythonAttrs (old: {
    buildInputs = [ pkgs."unzip" ];
  });

  "ZServer" = super."ZServer".overridePythonAttrs (old: {
    installFlags = [ "--no-deps" ];
    buildInputs = [ pkgs."unzip" ];
  });

}
