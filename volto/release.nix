{pkgs ? import <nixpkgs> {}
}:

let

  env = (import ./default.nix { inherit pkgs; }).package.override {
    src = builtins.filterSource (path: type:
      (baseNameOf path) == "Makefile" ||
      (baseNameOf path) == "package.json" ||
      (baseNameOf path) == "package-lock.json" ) ./.;
    preRebuild = ''
      substituteInPlace node_modules/@plone/volto/package.json \
        --replace "\"cypress\": \"3.6.1\"," "" \
        --replace "\"cypress-axe\": \"0.4.1\"," "" \
        --replace "\"cypress-file-upload\": \"3.5.0\"," "" \
        --replace "\"cypress-plugin-retries\": \"1.5.0\"," "" \
        --replace "\"husky\": \"4.2.1\"," ""
      rm -rf node_modules/cypress*
      rm -rf node_modules/husky
    '';
    postInstall = ''
      grep -srlZ "\-node-sources" |xargs -0 rm
    '';
  };

in

pkgs.stdenv.mkDerivation {
  name = "volto";
  src = pkgs.lib.cleanSource ./.;
  builder = builtins.toFile "builder.sh" ''
    source $stdenv/setup;
    mkdir -p $out/bin $out/lib
    cp -a $src $out/lib/volto && chmod u+w -R $out/lib/volto
    cd $out/lib/volto
    cp -a $env/lib/node_modules/volto-starter-kit/node_modules .
    node_modules/.bin/razzle build
    chmod u+w -R node_modules && rm -r node_modules
    echo "#!/usr/bin/env sh" >> $out/bin/volto
    echo "node $out/lib/volto/build/server.js $@" >> $out/bin/volto
    chmod u+x $out/bin/volto
    wrapProgram $out/bin/volto \
      --suffix PATH : $propagatedBuildInputs/bin \
      --suffix NODE_ENV : production \
      --suffix NODE_PATH : $env/lib/node_modules/volto-starter-kit/node_modules
  '';
  buildInputs = with pkgs; [ makeWrapper ];
  propagatedBuildInputs = with pkgs; [ nodejs-12_x ];
  inherit env;
}
