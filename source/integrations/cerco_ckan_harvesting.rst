.. _cerco_ckan_harvesting:

.. _ckan_harvesting:

=========================
Configurazione harvesting
=========================

Una volta impostate le varie applicazioni, si possono inserire in CKAN gli entrypoint su cui fare harvesting. 
Come da documento architetturale, le istanze di CKAN su nodi e su hub andranno ad eseguire l'harvesting su sorgenti diverse.

.. _ckan_harvesting_partner:

Configurazione harvesting su nodo partner
-----------------------------------------

Le istanze di CKAN sui singoli nodi andranno a fare harvesting solo sul GeoNetwork locale.

Autenticarsi su CKAN come utente ``harvest`` e andare alla pagina ``/harvest``.

Creare una nuova sorgente dati e configurarla nel seguente modo:

- Source of metadata: http://localhost/geonetwork/srv/eng/csw
- Source type: CSW
- Titolo: GeoNetwork locale (modificare a piacere)
- Descrizione: (a piacere, anche vuoto va bene)
- Configuration: ``{ "default_extras":{"gn_url":"http://84.33.2.28/geonetwork"}, "default_tags":["Geografico"] }``
   - ``default_extras`` aggiunge informazioni per risalire al metadato originale. 
     Si deve impostare  l'IP o il nome della macchina reale.
   - ``default_tags`` serve ad aggiungere il tag "Geografico" a tutti i metadati importati da GeoNetwork.

.. _ckan_harvesting_hub:

Configurazione harvesting su hub
--------------------------------

L'istanza di CKAN sull'hub dovrà andare ad effettuare harvesting sui CKAN dei nodi partner.

Autenticarsi su CKAN come utente ``harvest`` e andare alla pagina ``/harvest``.

Per ogni nodo partner, creare una nuova sorgente dati e configurarla nel seguente modo:

- Source of metadata: es: ``http://84.33.2.29`` (inserire indirizzo IP o nome del nodo partner)
- Source type: CKAN
- Titolo: es: ``CERCO - Provincia di Prato`` (modificare a piacere)
- Descrizione: (a piacere, anche vuoto va bene)
- Configuration: è un dict JSON che ammette i seguenti campi:
   - ``force_all``: scarica tutti i dataset remoti, forzando la comparazione con l'insieme di dati correnti 
       ed eliminando quelli non più presenti sul nodo remoto
   - ``default_tags``: tag da aggiungere ai dataset importati, da modificare a piacere
   - ``nodo_origine_cerco``: Informazioni sul nodo sorgente da visualizzare nella lista dataset; da modificare a piacere
   - ``harvest_url``: URL del dataset sul nodo originale
   - Questa è la configurazione tipo da inserire nella textarea (tag e nodo origine andranno modificati a seconda dell'URL harvestata)::
   
         { "force_all": true, 
           "default_tags":[{"name": "provincia-prato"}], 
           "default_extras": {
             "nodo_origine_cerco": "Provincia di Prato",
             "harvest_url": "{harvest_source_url}/dataset/{dataset_id}"}  
         }
   