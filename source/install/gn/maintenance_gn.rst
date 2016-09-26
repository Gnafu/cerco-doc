.. _reconfig_gn:

============
Manutenzione
============

----------------------------------------
Riconfigurazione di GN su una VM clonata
----------------------------------------

Per informazioni si come clonare una VM, seguire le istruzione alla sezione  :ref:`cloning_vm`.

Le sezioni seguenti mostrano come riconfigurare GeoNetworn su una VM clonata e riconfigurata.


Configurazioni su file
----------------------

Layer WMS sulla mappa di ricerca
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Modificare il server WMS server, i layer e la bounding box nel file esternalizzato, come spiegato nel paragrafo :ref:`gn_create_datadir`.  

Config on UI and DB
-------------------

DB configurations include the automatic UUID site generation. This info does not apply to you if you are using 
the RNDT schema plugin, because you will be setting the site ID by hand anyway.  

Anyway, to be sure you have a clean GeoNetwork DB, you'd better create a brand new DB.

Fermare il servizio GeoNetwork
------------------------------

Dato che stiamo riconfigurando una macchina clonata, dove GN è configurato per partire in automatico,
dovremo fermare il servizio GeoNetwork ::  

   service geonetwork stop

Configurazione del DB
---------------------

Come utente postgres eliminare il DB ::

   dropdb geonetwork
   
Quindi ricreare il DB da zero, seguendo i passi descritti nel paragrafo :ref:`gn_create_db`::

   createdb -O geonetwork  geonetwork
   psql -W -U geonetwork -d geonetwork -c "CREATE EXTENSION postgis;"
   psql -W -U geonetwork -d geonetwork -c "CREATE EXTENSION postgis_topology;"
   
Rilanciare GeoNetwork
---------------------
::

    service geonetwork start
    
Alla partenza, GeoNetwork rigenererà lo schema del DB, popolandolo con i necessari dati iniziali. 
    
Impostazioni su interfaccia Web
-------------------------------

Seguire i passi nel paragrafo :ref:`gn_web_config`.



