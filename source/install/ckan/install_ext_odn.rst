.. _install_ext_odn:

#################################
Installing ODN extension for CKAN
#################################

============
Introduction
============

The OpenDataNetwork extension provides customization for:

- general styling
- main page layout
- display of items in the dataset list
- display of item in dataset page
- categories filtering


.. hint::
   Ref info page at https://github.com/geosolutions-it/ckanext-odn


In this document you'll only find specific information for installing the ODN plugin for CKAN. 

It is expected that CKAN has already been properly installed and configured as described 
in :ref:`install_ckan`.


.. _extension_odn:

=============
ODN extension
=============

In order to install the ``ckanext-odn`` extension, copy (or clone using git) the ``ckanext-odn/`` directory inside 

Before using the plugin, the extension must be installed into the CKAN virtual environment.

As user ``ckan``::

   $ . /usr/lib/ckan/default/bin/activate
   (default)$ cd /usr/lib/ckan/default/src
   (default)$ git clone https://github.com/geosolutions-it/ckanext-odn.git
   (default)$ cd ckanext-odn
   (default)$ python setup.py develop

Once done, you can add the plugins that the ODN extension provides.

To enable it, edit file ``/etc/ckan/default/production.ini`` and add the plugins::  

   ckan.plugins = [...] odn_theme odn_harvest

Restart CKAN to make it load this new extension.
   
ODN configuration
-----------------

Configuration for ODN in ``.ini`` file.

``odn.map_link``

    The URL where the map link in the home page should point to. E.g.::
      
       odn.map_link = http://www.opendatanetwork.it/tolomeo/html/servizi/cerco/cerco.html?paramPreset=Cerco
