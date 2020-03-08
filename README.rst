============
Plone on Nix
============

*”I know what I'm doing...”*

Building and running a Docker image:

.. code:: bash

   docker load < $(nix-build release.nix -A image)

.. code:: bash

   docker run --rm -ti -p 8080:8080
