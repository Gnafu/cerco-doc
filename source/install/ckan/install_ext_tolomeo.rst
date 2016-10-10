.. _install_tolomeo_ext:

#####################################
Installing Tolomeo extension for CKAN
#####################################

.. hint::
   Repository at https://github.com/geosolutions-it/ckanext-tolomeo

============
Introduction
============

The Tolomeo extension enables the preview of WMS layers inside CKAN resource pages, using Tolomeo as map client.

In this document you'll find specific information for installing the Tolomeo plugin for CKAN. 

It is expected that CKAN has already been properly installed and configured as described 
in :ref:`install_ckan`.

You should also have an available Tolomeo installation. You can find deploy instruction for Tolomeo in :ref:`install_tolomeo`


.. _extension_tolomeo:

=================
Tolomeo extension
=================

Before using the plugin, the extension must be installed into the CKAN virtual environment.

As user ``ckan`` clone the repository::

   $ cd /usr/lib/ckan/default/src
   $ git clone https://github.com/geosolutions-it/ckanext-tolomeo.git

and install the extension in the virtual environment::

   $ . /usr/lib/ckan/default/bin/activate
   (default)$ cd ckanext-tolomeo
   (default)$ python setup.py develop

Once done, you should configure CKAN to use the plugin that the Tolomeo extension provides.
The provided plugin is called ``tolomeo_view``.  

Edit the file ``/etc/ckan/default/production.ini`` and add the plugin::  

   ckan.plugins = [...] tolomeo_view tolomeo_preset_view
   
Also add this view as one of the default views that will be added to new WMS resources::

   ckan.views.default_views = ... tolomeo_view tolomeo_preset_view
   
Once saved the ``.ini`` file restart CKAN. 


.. _extension_tolomeo_config:

Tolomeo configuration
---------------------

Tolomeo needs a couple of configuration info. You'll put these info into your ``.ini`` file.

``tolomeo.preset``

    This is the preset that will be used in the client side.
    ::
      
       tolomeo.preset = Cerco
       
``tolomeo.base_url``

    This is the URL to the Tolomeo instance that will be used in the CKAN instance.
    It may refer to the local Tolomeo installed in the node, or to some other external Tolomeo instance::
    
       tolomeo.base_url = http://www.opendatanetwork.it/tolomeo 
    



.. _extension_tolomeo_create_view:


Update existing WMS resource
----------------------------

In order to allow exising WMS resources to use the Tolomeo view, you have to associate the view to the resources.

Enable the virtual environment ::

   $ . /usr/lib/ckan/default/bin/activate
      
and run the command to create the missing views::

  paster --plugin=ckan views create    --config=/etc/ckan/default/production.ini
  
  
.. _setup_tolomeo_proxy:

==========================
Apache httpd configuration
==========================

If you didn't choose to install Tolomeo on the local server, but to use an external service instead, 
you'll have to setup the current node as a proxy for the ``/tolomeo`` calls, because some static resources (e.g. the icon images) 
may otherwise become unavailable. 

As ``root``, create the file ``/etc/httpd/conf.d/91-tolomeo.conf`` and add content similar to this::
 
   ProxyPass        /tolomeo   YOUR_REMOTE_SERVICE
   ProxyPassReverse /tolomeo   YOUR_REMOTE_SERVICE
   
for instance::

   ProxyPass        /tolomeo   http://www.opendatanetwork.it/tolomeo/
   ProxyPassReverse /tolomeo   http://www.opendatanetwork.it/tolomeo/


Once saved the new configuration, reload it ::

   systemctl reload httpd

