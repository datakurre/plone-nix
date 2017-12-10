{ pkgs, pythonPackages }:

self: super:  {
  Pillow = super.pillow;

  "BTrees" = super."BTrees".overridePythonAttrs (old: {
    installFlags = [ "--no-deps" ];
    buildInputs = [ self."persistent" self."zope.interface" ];
    propagatedBuildInputs = [];
  });

  "eggtestinfo" = super.buildPythonPackage {
    name = "eggtestinfo-0.3";
    src = pkgs.fetchurl {
      url = "https://pypi.python.org/packages/e0/8e/77c064957ea14137407e29abd812160eafc41b73a377c30d9e22d76f14fd/eggtestinfo-0.3.tar.gz";
      sha256 = "0s77knsv8aglns4s98ib5fvharljcsya5clf02ciqzy5s794jjsg";
    };
    doCheck = false;
  };

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

  "Products.DCWorkflow" = super."Products.DCWorkflow".overridePythonAttrs (old: {
    installFlags = [ "--no-deps" ];
    buildInputs = [ self."eggtestinfo" ];
    propagatedBuildInputs = [];
  });

  "Products.GenericSetup" = super."Products.GenericSetup".overridePythonAttrs (old: {
    installFlags = [ "--no-deps" ];
    buildInputs = [ self."eggtestinfo" ];
    propagatedBuildInputs = [];
  });

  "zope.security" = super."zope.security".overridePythonAttrs (old: {
    installFlags = [ "--no-deps" ];
    buildInputs = [ self."zope.interface" self."zope.proxy" ];
    propagatedBuildInputs = [];
  });

  "z3c.autoinclude" = super."z3c.autoinclude".overridePythonAttrs (old: {
    src = pkgs.fetchFromGitHub {
      owner = "datakurre";
      repo = "z3c.autoinclude";
      rev = "fd2eb5bccba9e18ec76daf88968d78a72871a49b";
      sha256 = "1cnifa99j02j79467m3z7p6l2d336r4dg5351rqzmazac4jzplw3";
    };
    installFlags = [ "--no-deps" ];
    propagatedBuildInputs = [];
  });

}
