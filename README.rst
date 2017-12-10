*”I know what I'm doing...”*

.. code:: bash

   make build
   mkdir -p var/filestorage
   cd var
   nix-build ../zconfig/instance.nix -o zope.conf
   ../build/bin/plonecli instance -C zope.conf run ../admin.py
   ../build/bin/plonecli instance -C zope.conf fg
