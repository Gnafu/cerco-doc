.. _install_ext_harvesters:

###########################
Installing other harvesters
###########################

============
Introduction
============

CKAN will gather informations from different sources.

According to the node role (central hub or parner node), CKAN will harvest either other CKAN instances or a GeoNetwork catalog. 

.. _install_ext_harvesters_geonetwork:

====================
GeoNetwork harvester
====================

Introduction
------------

GeoNetwork is an opensource metadata catalog which provides `CSW <http://www.opengeospatial.org/standards/cat>`_ services.

GeoNetwork may be queried and harvested using the official CSW harvester provides with the 
`ckanext-spatial <https://github.com/ckan/ckanext-spatial>`_ extension, anyway some more functionalities can be 
added using the Geonetwork own API, such as mapping GeoNetwork categories onto CKAN groups.

The `GeoNetwork harvester <https://github.com/geosolutions-it/ckanext-geonetwork>`_ provides such extended functionalities.


Installing the GeoNetowrk harvester plugin
------------------------------------------

Before using the plugin, the extension must be installed into the CKAN virtual environment.

As user ``ckan``::

   $ . /usr/lib/ckan/default/bin/activate
   (default)$ cd /usr/lib/ckan/default/src
   (default)$ git clone https://github.com/geosolutions-it/ckanext-geonetwork.git
   (default)$ cd ckanext-geonetwork
   (default)$ python setup.py develop

Once done, you have to add to CKAN the plugin ``geonetwork_harvester`` that the extension provides.

To enable it, edit file ``/etc/ckan/default/production.ini`` and add the plugin::  

   ckan.plugins = [...] geonetwork_harvester
      
Then restart CKAN to make it load this new extension.  
