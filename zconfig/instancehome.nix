# Plone expects Zope2 to load ``./etc/site.zcml`` from ``instancehome``.

{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "instancehome";
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

      <include package="collective.folderishtypes" />
      <include package="pas.plugins.ldap" />
      <include package="plonetheme.barceloneta" />
      <include package="plone.restapi" />
      <include package="yafowil.plone" />

      <include package="plone.rest" file="meta.zcml" />
      <plone:CORSPolicy
          allow_origin="http://localhost:3000,http://127.0.0.1:3000"
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
}
