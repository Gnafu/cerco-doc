.. _integrckanspatial:

CKAN spatial extension
######################

CKAN does not support spatial information in its core code.

There are 2 plugins that will make CKAN integrate with CSW catalogs. 

Harvest extension
   The harvest plugin provides a basic frmaework for managing harvesting jobs.
   https://github.com/okfn/ckanext-harvest/

Spatial extension
   Spatial plugin extends the CKAN model to provide some spatial functionalities.
   In particular, we'll use the CSW harvesting capabilities to harvest data from a 
   GeoNetwork instance, and the mapping/model extension to map ISO19139 metadata into 
   CKAN model.   
   https://github.com/okfn/ckanext-spatial


CKAN harvests GeoNetwork metadata using the CSW protocol, asking for metadata in ISO19139 format.
Such metadata shall be converted in a format suitable for CKAN (as described in next section :ref:`mapping19139`)
and then ingested.
