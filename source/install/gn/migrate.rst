.. _gn_migration:

===================
Migrazione metadati
===================

GeoNetwork fornisce delle procedure interne per la migrazione automatica dello schema del DB da un versione all'altra. Purtroppo
tale meccanismo non sempre è affidabile e potrebbe lasciare la migrazione incompleta, rendendo instabile il sistema.

Tra l'altro, nella migrazione verso un sistema conforme a RNDT, i metadati esistenti dovranno essere modificati per soddisfare i requisiti
imposti dallo schema plugin RNDT   

Quello che andremo a fare è quindi un setup da zero del sistema, importando i metadati esportati dal sistema da migrare.

Esportazione metadati
---------------------

Dal sistema da migrare serve esportare i metadati in formato MEF.
Il formato MEF è in pratica un file zip nel cui interno sono presenti:

- il metadato (file ``metadata.xml``),
- gli eventuali dati associati al metadato, se gestiti da GeoNetwork
- altri meta-metadati di gestione del metadato (contenuti nel file ``info.xml``).

Da GeoNetwork è possibile esportare uno zip contenente più MEF:

#. dalla schermata di ricerca, selezionare in metadati che si vuole esportare
#. dalla dropdown "azioni sulla selezione" selezionare la voce "esporta (ZIP)"

Si suggerisce di non selezionare troppi metadati alla volta, pena il fallimento della chiamata per problemi di *out of memory*.

.. _gn_migration_modify:

Processamento dei meta-metadati
-------------------------------

GeoNetwork permette di importare un insieme di file MEF, effettuando una trasformazione XSL sui metadati prima di inserirli.

La trasformazione ci permetterà di rendere il metadato compatibile con lo schema plugin RNDT, compresa la modifica 
del ``fileIdentifier``.

Un problema che abbiamo è che GeoNetwork importerà i metadati usando alcune informazioni esterne al metadato stesso, 
ossia contenute in un file di meta-metadati (``info.xml``). 
In particolare il ``fileIdentifier`` assegnato alla scheda di metadato non sarà estratto
dal metadato stesso, ma sarà usato l'identificatore indicato nel file ``info.xml``.

Dovremo quindi andare a modificare i file ``info.xml`` all'interno di tutti i file ``.MEF``, aggiornando 
l'identificatore nello stesso modo in cui l'XSL di importazione lo modificherà all'interno del metadato nel 
momento in cui andremo ad ingerire i MEF all'interno di GeoNetwork. 

File MEF di origine
___________________

All'interno di una directory ``MIGRATE/`` (nome arbitrario) andiamo a creare la directory ``orig/`` dove andranno copiati tutti i file
``.MEF`` esportati da GeoNetwork.

Un esempio potrebbe essere ``/var/lib/tomcat/geonetwork/MIGRATE/``.

Decompressione file MEF
_______________________
 
Creare la directory ``unzipped``::

   mkdir unzipped

e decomprimere tutti i file ``MEF`` al suo interno::
   
   for mef in orig/*.mef ; do file=$(basename $mef); echo === $file; mkdir unzipped/$file ; unzip $mef -d unzipped/$file ; done

Modifica file ``info.xml``
__________________________

Con il seguente comando andremo a modificare tutti i file ``info.xml``, aggiungendo il codice iPA
a tutti gli UUID:: 
 
   for info in $(find unzipped/ -name info.xml) ; do sed -i -e 's/<uuid>/<uuid>cmfi:/g' $info ; done

In questo caso si è usato il codice ``cmfi``. Se si stanno rimappando file di un'altro Ente, modificare il comando 
in modo da aggiungere nei file l'iPA corretto. 

Ricreare i MEF
______________

Creare la direcotry ``rezipped``::

   mkdir rezipped
   
a ricreiamo i file MEF con i file ``info.xml`` aggiornati:: 
   
   for mef in unzipped/*.mef ; do file=$(basename $mef); echo === file $file; cd $mef ; zip -r ../../rezipped/$file *; cd -  ; done


A questo punto avremo nella directory``MIGRATE/rezipped`` tutti i file ``.MEF`` pronti da essere importati in GeoNetwork. 


.. _gn_migration_import:

Importazione dei metadati
-------------------------

Una volta che si hanno i file MEF dei metadati da reimportare, occorre che siano posizionati in 
una directory *sul server in cui si intende reimportare i metadati*.

Da amministratore, andare in *Amministrazione* > *Importazione multipla*

Qui servirà indicare:

- Directory: posizione sul serve dove di trovano i file MEF
- Tipo di file: *file MEF*
- Imposta azioni: *nessuna azione in fase di import*
- Foglio di stile: scegliere dalla dropdown *gn28-to-gn210rndt-cmfi*
- Impostare il segno di spunta su *Assegna al catalogo corrente*

Il foglio di stile selezionato andrà a modificare il metadato in ingresso in modo da impostare alcuni campi
richiesti da RNDT. Inoltre verrà impostato il codice iPA per il Comune di Firenze nei metadati impostati.

.. note::
   L'importazione molto probabilmente impiegherà diversi minuti prima di essere completata.
    
   Dato che la richiesta da browser è sincrona, il proxy HTTPD rileverà inattività da parte del server (che invia responso solo 
   alla fine dell'importazione) e restituirà un *Internal Server Error*.
   In realtà l'importazione sarà ancora in esecuzione lato server, per cui alla fine dell'importazione tutti i metadati 
   saranno disponibili sul catalogo.
   
   Dato che però la schermata finale dei risultati non sarà visibile lato client, dato l'errore pregresso, si raccomanda di 
   controllare che il numero di record nel catalogo sia quello aspettato, ed eventualmente controllare i log sul server. 

Volendo importare all'interno della stessa istanza di GeoNetwork metadati appartenenti a PA diverse, 
si dovranno avere i diversi set di metadati all'interno di directory diverse nel server, ed eseguire l'importazione
in passi separati per ogni PA, indicando di volta in volta la diversa directory e il diverso foglio di stile da usare.
Andranno chiaramente usati fogli di stile diversi per PA diverse, in quando il codice IPA da assegnare è impostato all'interno del 
foglio di stile stesso.

Log di importazione
___________________

I log dell'XSL di migrazione si troveranno nel file :: 

   /var/lib/tomcat/geonetwork/logs/catalina.out

Il formato dei log è::

   ====== IMPORTAZIONE METADATO ccb8143c-567c-4785-bfb4-2ed559570470
   == CRS EPSG: RNDT ROMA40/OVEST
   == Spostamento distributor
   
CRS
   - ``CRS EPSG:`` significa che è stato trovato un codice EPSG nel documento.
   
      - ``RNDT`` *nome crs* significa che è stato possibile esprime il codice EPSG in formato RNDT. 
      - ``EPSG`` *codice crs* significa che non è stato possibile esprime il codice EPSG in formato RNDT, e quindi si è usata la codifica EPSG.

   - ``CRS:`` significa che si sta cercando si parsare un codice non esplicitamente dichiarato come EPSG. 
    
   Nel caso non sia stato possibile trovare o parsare il codice sarà presentato un messaggio esplicito.
   
Spostamento distributor
   Indica che è stato trovato un PoC con ``role`` ``distributor`` nei dati, ed è stato quindi spostato nell'elemento ``MD_Distribution``.
   
   Nel caso non sia trovato un PoC distributor, sarà copiato il ``gmd:contact``, e sarà loggata la riga::  
   
      ==== FORZA POC COME DISTRIBUTOR
      
AggregateInformation

   Nel caso si riscontrino errori in ``AggregateInformation`` saranno loggati i relativi errori:
   
   - ``==== Errore di compilazione in AggregateInformation``
   - ``== Eliminazione initiativeType vuoto``

``gmd:contact``      

   Nel caso in cui il ``gmd:contact`` non sia presente o non abbia il ``roleCode`` corretto, sarà loggata la riga::
   
      ==== Errore: PoC metadato non trovato
      

.. _gn_migration_import_xsl:

Creazione di XSL di importazione
--------------------------------

Il processo di importazione di metadati per la varie PA coinvolte nel progetto OpenDataNetwork dovrebbe essere
più o meno lo stesso per tutti i metadati nei vari cataloghi. 
Potrebbero esserci delle variazioni nel caso in cui una PA abbia personalizzato i template dei metadati in qualche modo,
nel qual caso le trasformazioni andranno esaminate caso per caso.

Nel caso standard, per creare un XSL che inserisca il codice IPA dove necessario, basterà 
copiare il file ::  

   /var/lib/tomcat/geonetwork/webapps/geonetwork/WEB-INF/data/config/schema_plugins/iso19139.rndt/convert/import/gn28-to-gn210rndt-cmfi.xsl
          
in un nuovo file all'interno della stessa directory.

Nel nuovo file si dovrà andare quindi andare a modificare il codice IPA nella riga::

    <xsl:variable name="IPA" select="'cmfi'" />


