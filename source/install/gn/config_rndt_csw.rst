.. _config_gn_rndt_csw:

==================
Configurazione CSW
==================
   
Configurazione Enti su CSW
--------------------------
   
Il servizio CSW offerto da GeoNetwork gestirà tutto l'insieme dei metadati pubblici contenuto.
Questo significa che i contenuti afferenti a diversi Enti potranno essere ritornati all'interno di una stessa risposta da parte
del servizio CSW.

In generale questo è un comportamento desiderato, ma potremmo avere bisogno di un entrypoint CSW che esponga i soli metadati di un 
determinato Ente. Andiamo quindi a creare degli endpoint virtuali. 


Server CSW virtuali
___________________
  
.. note::
   Prima di eseguire i passi descritti in questa sezione, leggere anche la sezione successiva (:ref:`install_gn_csw_services`)
   che descrive l'approccio migliore per la creazione dei servizi CSW necessari.

Entrare in "Amministrazione" > "Configurazione CSW virtuali" > "Aggiungi un servizio".
 
Aggiungiamo ad esempio un endpoint virtuale che restituisca soltanto i metadati del Comune di Firenze:

- Nome del servizio: ``csw-comune-firenze-rndt``
- Descrizione del servizio: *Servizio di catalogo del Comune di Firenze*
- Testo libero: ``c_d612``

Allo stesso modo si andranno a configurare gli altri entrypoint per gli altri enti, usando diversi nomi di servizio.

.. note::
   I nomi servizio dovranno iniziare con la stringa ``csw-`` per permettere allo strato di sicurezza di riconoscere che
   si tratta di un servizio CSW.
 
L'entrypoint virtuale sarà accessibile alla URL ``http://SERVER/geonetwork/srv/ita/csw-comune-firenze-rndt``.
Questo servizio filtrerà preventivamente i metadati usando i vincoli richiesti: in questo restituirà solo metadati che contengono la stringa ``c_d612``, 
stringa che è presente come parte del codice di identificazione.
    
La definizione degli entrypoint virtuali in questo modo è però poco precisa, in quanto il filtraggio sulla stringa inserita è effettuata su
*Testo libero*, ossia un indice che contiene la quasi totalità dei campi di testo del metadato. Questo significa che se, in un metadato qualsiasi,
anche non appartenente al Comune Firenze, appare la stringa ``c_d612`` ad esempio nel campo *Descrizione*, quel metadato sarà restituito dal 
server CSW virtuale.
Questo è dovuto al fatto che la definizione dei CSW virtuali da interfaccia web non permette il filtraggio sul campo ``fileIdentifier``.

Volendo, si potranno creare gruppi o categorie per organizzare i metadati delle varie PA, ma questo fa perdere gli automatismi di assegnazione, 
in quanto, oltre ad editare il metadato, gli si dovrebbe assegnare manualmente categoria o gruppo.

Per avere più flessibilità nel filtraggio dei metadati desiderati, dovremo andare a creare manualmente dei servizi CSW nei file di 
configurazione di GeoNetwork.  

.. _install_gn_csw_services:

Configurazione manuale di servizi CSW
_____________________________________

Nel file ``/var/lib/tomcat/geonetwork/webapps/geonetwork/WEB-INF/config-csw-servers.xml``
possiamo creare nuovi servizi CSW, con la possibilità di:

- definire filtri che operino solo in un sottoinsieme dei metadati;
- definire un file XSL per trasformare il metadato unin uscita.


Per aggiungere un servizio CSW che ritorni i soli metadati della Città Metropolitana di Firenze, editare il file :: 
  
   vim /var/lib/tomcat/geonetwork/webapps/geonetwork/WEB-INF/config-csw-servers.xml
   
ed aggiungere un servizio in questo modo::

   <service name="csw-cmfi-rndt">
      <class name=".services.main.CswDiscoveryDispatcher" >
          <param name="filter" value="+ipa:cmfi"/>
      </class>
   </service>
  
Il **service name** (in questo caso ``csw-cmfi-rndt``) è la parte finale della URL dell'entrypoint CSW, ossia   
``http://SERVER/geonetwork/srv/ita/csw-cmfi-rndt``. Il nome è arbitrario, ma deve inizare con ``csw``.

Il **filtro** è nella forma ``+ipa:CODICEIPA``. ``ipa`` è un indice sul codice iPA creato dal plugin RNDT. 
In questo modo questo servizio ritornerà esclusivamente i metadati con il ``CODICEIPA`` richiesto, evitando gli eventuali problemi citati
nella sezione precedente. 
Ulteriore esempio: nel caso si fosse dovuto filtrare i metadati del Comune di Firenze, il filtro sarebbe stato ``"+ipa:c_d612"``.

 
Configurazione output ISO
_________________________

La configurazione manuale dei servizi CSW, come detto sopra, permette anche di definire un XSL che andrà a modificare 
il metadato presentato all'esterno.

Questo ci permette di creare endpoint CSW diversi che presentano il metadato in formati diversi. Il plugin RNDT formatta il metadato seguendo
le specifiche richieste dal Repertorio Nazionale. Dato che esistono peer esterni che richiedono di rimuovere i valori di alcuni campi caratteristici
di RNDT (es.: ``parentIdentifier``), potremo creare un endpoint CSW che presenti i metadati in un formato più orientato alla semantica ISO.

L'output di un servizio GeoNetwork può essere postprocessato da un foglio XSL aggiungendo l'elemento::
 
   <output sheet="nomefile.xsl" />
   
Per cui, per configurare un servizio CSW che gestisca i metadati della Città Metropolitana di Firenze e li fornisca in formato "ISO", 
dovremo aggiungere un ulteriore servizio nel file ``config-csw-servers.xml``::

   <service name="csw-cmfi">
      <class name=".services.main.CswDiscoveryDispatcher" >
          <param name="filter" value="+ipa:cmfi"/>
      </class>
      <output sheet="rndt2iso.xsl" />
   </service>

Avremo così i due diversi servizi:

- ``http://SERVER/geonetwork/srv/ita/csw-cmfi``      per l'output ISO
- ``http://SERVER/geonetwork/srv/ita/csw-cmfi-rndt`` per l'output RNDT

