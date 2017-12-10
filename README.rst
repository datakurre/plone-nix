*”I know what I'm doing...”*

.. code:: bash

   make
   mkdir -p plone/filestorage
   cd plone
   nix-build ../zconfig/instance.nix -o zope.conf
   ../result/bin/plonecli instance -C zope.conf run ../admin.py
   ../result/bin/plonecli instance -C zope.conf fg
