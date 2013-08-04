.. _inttolockan:

CKAN-Tolomeo integration
########################


Recognized Resources type
-------------------------
**TODO** 

Resource types in GN:
 - WMS getMap layer
 - Tolomeo preset
 

Resource preview
----------------

Tolomeo is used in the preview in the :ref:`ckannavresourceview` page only for "WMS getMap" resources.
A site-specific preset is loaded in Tolomeo, and the WMS layer is then added to it.

Resources referring to a preset are not showed in preview, for different reasons:
 - preset and local Tolomeo version may mismatch, breaking the CKAN page;
 - controls required in a preset may use too much room, usually not available in the small
   preview panel.       

Using full Tolomeo client
-------------------------

The local Tolomeo instance can be recalled from the main page, following the link "Go to the map client".
The default preset can be defined in a site-wide configuration. 

Furthermore, when viewing :ref:`ckannavresourceview` of a WMS getMap resource, you can display the layer
in the full-featured standalone Tolomeo client using the upper right button (see :ref:`ckannavresourceviewspatial`). 