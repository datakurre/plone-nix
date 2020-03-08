============
Plone on Nix
============

*”I know what I'm doing...”*

Building a Docker image:

.. code:: bash

   docker load < $(nix-build release.nix -A image)

Running the backend:

.. code:: bash

   docker run --rm -ti -p 8080:8080 volto:latest

Running the frontend:

.. code:: bash

   docker run --rm -ti -p 3000:3000 --entrypoint=/bin/volto volto:latest
