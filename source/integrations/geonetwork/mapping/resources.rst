.. _mappingresources:

Mapping resources
#################

When editing an ``onlineResource`` in GeoNetwork, it has to be associated to a resource type. The GeoNetwork metadata editor
shows a dropdown menu to offer a list of resource types.

CKAN will only import resources which resource type can be properly handled, in particular:

HTTP Link
   Will be handled as a link
HTTP download
   Will be handled as a downloadable file if *mime-type* in GeoNetwork metadata tells it's a *zip* or a *tgz* file.  
:term:`WMS` GetMap
   It's completely handled in CKAN, by using Tolomeo for previewing the resource in the :ref:`ckannavresourceview` page, and
   by providing a link to a full tolomeo instance with that WMS layer preloaded
:term:`TOLOMEO` preset
   It's a resource type provided by a customization in GeoNetwork (see :ref:`cerco_deploy_gn`). 
   This is a link pointing to a Tolomeo preset (a web map context enriched with configuration details for the Tolomeo 
   client application), and will be handle in CKAN by providing a link in the :ref:`ckannavresourceview` page to a Tolomeo
   instance with that preset preloaded.
    