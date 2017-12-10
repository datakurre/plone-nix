============
Plone on Nix
============

*”I know what I'm doing...”*

Building and running a Plone instance:

.. code:: bash

   make build
   mkdir -p var/filestorage
   cd var
   nix-build ../zconfig/instance.nix -o zope.conf
   ../build/bin/plonecli instance -C zope.conf run ../admin.py
   ../build/bin/plonecli instance -C zope.conf fg

Building a Docker image:

.. code:: bash

   nix-build setup.nix -A bdist_docker
   docker load < result
