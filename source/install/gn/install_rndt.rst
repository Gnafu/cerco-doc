.. _install_gn_rndt:

===================
RNDT schema plugins
===================

In questa sezione si descrive l'installazione e la configurazione del plugin RNDT.

.. note::
   La repository del codice relativo al plugin RNDT si trova su questa pagina: https://github.com/geonetwork/schema-plugins/tree/2.10.x/iso19139.rndt

Installazione
-------------

Per installare uno schema plugin si deve fornire a GeoNetwork lo ZIP file contenente il plugin, o tramite upload del file, o indicando 
a GeoNetwork la URL dove poter scaricare il file.


Nell'interfaccia web di GeoNetwork, andare in "Amministrazione" >  "Metadati & Modelli" >  "Aggiungi uno schema/profilo di metadati".

- Impostare il nome dello schema a ``iso19139.rndt``
- Impostare come URL del file zip   
  http://build.geo-solutions.it/geonetwork/2.10.x/RNDT/iso19139.rndt.zip
- Premere "Aggiungi"

Tornando nella schermata di Amministrazione comparirà ``iso19139.rndt`` nella lista degli schemi.

- Selezionare ``iso19139.rndt`` e premere "Aggiungi modello"
- Opzionalmente, se si vogliono aggiungere metadati di esempio per lo schema RNDT, 
  selezionare ``iso19139.rndt`` e premere "Aggiungi alcuni metadati di esempio" 

XSL di pubblicazione CSW
________________________

Copiare il :download:`file XSL <resources/rndt2iso.xsl>` nella directory 
``/var/lib/tomcat/geonetwork/webapps/geonetwork/xsl/rndt2iso.xsl``.


Questo è il file che permette di avere servizi CSW che presentino metadati RNDT in formato ISO (vedi :ref:`install_gn_csw_services`).

XSL di importazione
___________________

Creare la directory :: 

    mkdir /var/lib/tomcat/geonetwork/webapps/geonetwork/WEB-INF/data/config/schema_plugins/iso19139.rndt/convert/import
    
Copiare il :download:`file XSL <resources/gn28-to-gn210rndt-cmfi.xsl>` nella directory
``/var/lib/tomcat/geonetwork/webapps/geonetwork/WEB-INF/data/config/schema_plugins/iso19139.rndt/convert/import/gn28-to-gn210rndt-cmfi.xsl``.

Es.::

   cd ~/download
   wget http://demo.geo-solutions.it/share/opendatanetwork/doc/online/_downloads/gn28-to-gn210rndt-cmfi.xsl
   cp gn28-to-gn210rndt-cmfi.xsl /var/lib/tomcat/geonetwork/webapps/geonetwork/WEB-INF/data/config/schema_plugins/iso19139.rndt/convert/import

Questo file è usato in fase di importazione (vedi :ref:`gn_migration_import`) per i metadati della Città Metropolitana di Firenze.

Per importare metadati afferenti a diverse PA servirà creare file *xsl* appositi; far riferimento alla sezione :ref:`gn_migration_import_xsl`.

Configurazione Enti PA
----------------------

Il plugin RNDT richiede che sia configurata una mappatura tra gli iPA e i nome degli Enti di Pubblica Amministrazione 
che si vorranno usare sull'istanza di GeoNetwork.

Questa mappatura si effettua tramite un elemento XML in questo formato::

   <rndt>
      <ente>
          <name>Regione Toscana</name>
          <ipa>r_toscan</ipa>
      </ente>
      <ente>
          <name>Provincia di Prato</name>
          <ipa>p_po</ipa>
      </ente>
      <ente>
          <name>Comune di Prato</name>
          <ipa>c_g999</ipa>
      </ente>
      <ente>
          <name>Città Metropolitana di Firenze</name>
          <ipa>cmfi</ipa>
       </ente>
       <ente>
           <name>Comune di Firenze</name>
           <ipa>c_d612</ipa>
       </ente>
   </rndt>
   
Questa definizione viene letta dal file ``config-gui.xml``. Dato che questo file è dentro la webapp, e verrà quindi sovrascritto 
ad ogni reinstallazione, andremo ad inserire tale configurazione all'interno del file di override precedentemente creato in  
``/var/lib/tomcat/geonetwork/gn/config-overrides.xml``.
 
Se si è installato il file come da istruzioni nella sezione :ref:`gn_create_datadir`, dovreste già avere all'interno del file di override 
l'elemento ``<rndt>`` con le PA di esempio riportate sopra.
Si dovrà quindi andare ad editare tali informazioni, aggiungendo o rimuovendo i vari elementi, con le PA che si intende utilizzare realmente.
 
Una volta effettuata la modifica, si dovrà riavviare GeoNetwork::
 
   systemctl restart tomcat@geonetwork
