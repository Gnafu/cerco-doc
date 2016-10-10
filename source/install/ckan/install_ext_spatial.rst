.. _install_ckan_spatial:

==============
Spatial plugin
==============

The *spatial* plugin allows CKAN to harvest spatial metadata (ISO 19139) using the CSW protocol.

DB configuration
----------------

Add the spatial extension to the ``ckan`` DB::

   # su - postgres -c "psql ckan"
   ckan=# CREATE EXTENSION postgis;
   ckan=# GRANT ALL PRIVILEGES ON DATABASE ckan TO ckan;
   ckan=# GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ckan;

You can check the installed PostGIS version by using::

   SELECT postgis_full_version();


Installing spatial libs
-----------------------

As root install the needed ``geos`` libs (needed for compiling Shapely)::

    yum install geos-devel geos-python
    

Installing ckan spatial
-----------------------

As user ``ckan``::

   . default/bin/activate
   cd /usr/lib/ckan/default/src
   git clone https://github.com/ckan/ckanext-spatial.git
   cd ckanext-spatial     
   pip install -e .
   pip install -r pip-requirements.txt


If you need to display a **WMS base layer** in the extent map,
check if the PR #163 (https://github.com/ckan/ckanext-spatial/pull/163) has been merged into official ckanext-spatial,
otherwise use a forked version that already contains the required feature::

   cd /usr/lib/ckan/default/src/ckanext-spatial
   git remote add forked https://github.com/geosolutions-it/ckanext-spatial.git
   git fetch forked
   git checkout --track forked/162_wms_layers
   pip install -e .


Init spatial DB
---------------

Init database, where 4326 is the default SRID::

   (pyenv)$ cd /usr/lib/ckan/default/src/ckan
   (pyenv)$ paster --plugin=ckanext-spatial spatial initdb 4326 --config=/etc/ckan/default/production.ini

   
Config
------

Edit file ``/etc/ckan/default/production.ini`` and add the spatial related plugins::  

   ckan.plugins = [...] spatial_metadata spatial_harvest_metadata_api spatial_query csw_harvester

You may also specify the default SRID::

   ckan.spatial.srid = 4326
   
Add the info to display a WMS base layer in the extent map::   
   
   ckanext.spatial.common_map.type = wms
   ckanext.spatial.common_map.wms.url = http://pubblicazioni.provincia.fi.it/geoserver/sfondi/service=wms
   ckanext.spatial.common_map.wms.layers = SfondoCercoLight
   ckanext.spatial.common_map.wms.styles =
   ckanext.spatial.common_map.wms.format = image/png
   ckanext.spatial.common_map.wms.srs = 
   ckanext.spatial.common_map.wms.version = 1.1.1
   ckanext.spatial.common_map.wms.attribution =
   

Metadata validation
'''''''''''''''''''

You may force the validation profiles when harvesting::

   ckan.spatial.validator.profiles = iso19139,gemini2,constraints
   
CKAN stops on validation errors by default. 
If you want to import also metadata that fails the XSD validation you need to add this line to the 
``.ini`` file::
   
   ckanext.spatial.harvest.continue_on_validation_errors = True
   
This same behavior can also be defined on a per-source base, setting 
``continue_on_validation_errors`` in the source configuration.

WMS resources validation
''''''''''''''''''''''''

When importing data, the spatial harvester can optionally check if the WMS services pointed to
the resources are reachable and working. To enable this check, you have to add this line to the 
``.ini`` file::   

   ckanext.spatial.harvest.validate_wms = true
   
If the service is working, two extras will be added to the related resource: ``verified`` as ``True`` 
and ``verified_date`` with the timestamp of the verification.


.. _configure_spatial_search:

Configure Spatial search
''''''''''''''''''''''''

.. hint::
   Ref info page at http://ckan.readthedocs.org/projects/ckanext-spatial/en/latest/spatial-search.html

In order to show the widget for the spatial search, you have to:

* index the bbox in Solr and 
* add the spatial search widget

Solr
____

Edit file ``/etc/ckan/default/production.ini`` and add this line to configure the spatial backend:: 

   ckanext.spatial.search_backend = solr

Edit the Solr schema file (remember, it's a symlink)::

   vim /etc/solr/ckan/conf/schema.xml
   
and add the ``field`` elements::

   <fields>
      <!-- ... -->
      <field name="bbox_area" type="float" indexed="true" stored="true" />
      <field name="maxx" type="float" indexed="true" stored="true" />
      <field name="maxy" type="float" indexed="true" stored="true" />
      <field name="minx" type="float" indexed="true" stored="true" />
      <field name="miny" type="float" indexed="true" stored="true" />
   </fields>

Then update Solr clause configuration.
As ``root``, edit the file ``/etc/solr/ckan/conf/solrconfig.xml`` and 
update the value of ``maxBooleanClauses`` to 16384.

Restart Solr to make it read the config changes::

   systemctl restart tomcat@solr
   
If your CKAN instance already contained spatial datasets, you may want to reindex the catalog::

   . /usr/lib/ckan/default/bin/activate
   paster --plugin=ckan search-index rebuild_fast --config=/etc/ckan/default/production.ini
      


