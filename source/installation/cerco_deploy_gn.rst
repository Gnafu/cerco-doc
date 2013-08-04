.. _cerco_deploy_gn:

#############################################
Installazione e configurazione GeoNetwork 2.8
#############################################

Version 1.2
07/05/2013

============
Introduzione
============

In questo documento sono esplicitate solo le informazioni per l’installazione di GeoNetwork.

Si presuppone che il sistema base sia già stato installato e configurato come descritto nel documento :ref:`cerco_setup_vm`, 
dove sono descritte le procedure per installare il sistema operativo CentOS 6.3 ed alcune utility di base.

In particolare dovranno essere stati installati:

- PostgreSQL e PostGIS
- Oracle Java
- Apache Tomcat
- Apache HTTPD

==============
Configurazioni
==============

Si riportano per comodità alcune informazioni relative al sistema installato:

- OS: Centos 6.3 64bit
- Hostname: cerco
- Indirizzo IP: 84.33.2.27
- Processors: 1 processore, 2 core
- Memory: 4096MB
- GeoNetwork: http://84.33.2.27/geonetwork 

========================
Installazione GeoNetwork
========================

La versione installata sui nodi CERCO è la **2.8**, per omogeneità con la versione usata in Regione Toscana.

Sono stati effettuati alcuni fix per quanto riguarda i file di localizzazione italiana, ed alcune customizzazioni:

- aggiunta del tipo di risorsa ``TOLOMEO:preset``;
- il file di default forza la lingua italiana:
- aggiunto il servizio ``metadata.show.minimal``, che offre un servizio di visualizzazione minimale per i metadati. 
  Questo servizio è richiamato nelle pagine di visualizzazione di CKAN.

Queste modifiche sono riportate nel file http://demo.geo-solutions.it/share/cerco/gn/webapps_geonetwork_update.tgz

File da scaricare
-----------------

Questi sono i file necessari per l’installazione di GeoNetwork

- distribuzione ufficiale di GeoNetwork 2.8.0:
    http://garr.dl.sourceforge.net/project/geonetwork/GeoNetwork_opensource/v2.8.0/geonetwork.war
- modifiche per CERCO alla distribuzione ufficiale:
    http://demo.geo-solutions.it/share/cerco/gn/webapps_geonetwork_update.tgz
- file di personalizzazione usato da tomcat: include alcuni override di GeoNetwork tramite variabili d'ambiente:
    http://demo.geo-solutions.it/share/cerco/gn/setenv.sh
- struttura per le directory di lavoro usate da GeoNetwork; include anche il file di *override* XML:
    http://demo.geo-solutions.it/share/cerco/gn/gn.tgz
- File di servizio per init:
    http://demo.geo-solutions.it/share/cerco/gn/geonetwork 

=========================
Configurazione GeoNetwork
=========================

Esternalizzazione delle configurazioni
--------------------------------------

GeoNetwork 2.8 permette di esternalizzare alcune configurazioni; parte di queste può essere gestita 
tramite *variabili di sistema* java, mentre per altre si deve usare un file di configurazione XML.

Queste esternalizzazioni permettono di evitare di modificare i file di configurazione esistenti 
all'interno del `.war` scompattato, come ad esempio i dati di connessione al DB. 
Si possono inoltre inizializzare alcuni valori che verranno inseriti nel DB, evitando quindi 
alcuni passi di configurazione da UI.

Le modalità di esternalizzazione sono principalmente due:

- impostazione di variabile di sistema java (opzione ``-D`` dell'eseguibile java)
- file xml di override, dove vengono definiti `xpath` e contenuti dei file di configurazione di geonetwork da modificare.

Directory dati
--------------

Una delle configurazioni esternalizzate di GeoNetwork è la posizione della data directory. 
Questa è solitamente interna alla webapp; posizionarla esternamente significa proteggerla 
da eventuali reinstallazioni della webapp.

Da test effettuati, spostare tutta la datadir esternamente alla webapp comporta problemi a runtime, 
dato che sembra che alcuni file XSL importino degli stylesheet dalla datadir usando path relativi.

Andremo quindi a definire singolarmente le subdir della data directory che ci interessano.

Posizioneremo le dir esternalizzate all'interno di ``/var/lib/tomcat/geonetwork/gn`` , in questa struttura::

    gn
    ├── data
    │   ├── metadata_data
    │   ├── metadata_subversion
    │   └── resources
    │       └── images
    │           └── logos
    ├── index
    │   └── nonspatial
    └── upload

La posizione delle directory è definiata parzialmente tramite variabili di sistema java, e parzialmente usando il file di override.

Database
--------

Le informazioni di connessione al database sono di solito contenute nel file ``config.xml``.

Si possono esternalizzare tramite il file di override.


Layer per la mappa di ricerca
-----------------------------

La UI di GeoNetwork gestisce di default 2 mappe: una mappa di ricerca sulla sinistra, ed una mappa per l'anteprima dei dati geografici metadatati.

È possibile modificare il bounding box di default e la lista dei layer usati tramite il file di override.

Notare che:

- ``<mapSearch>`` gestisce le informazioni della mappa di ricerca
- ``<mapViewer>`` gestisce le informazioni della mappa di anteprima

Info sul sito
-------------

Le informazioni riguardanti il sito (nome del sito, organizzazione) sono salvate su DB.

Di norma è possibile personalizzare queste informazioni tramite UI di amministrazione, ma, 
onde rendere replicabile l'installazione senza operazioni interattive, è possibile inserire 
queste informazioni nel file di override, che provvederà a modificare i relativi valori 
di default con quelli configurati. 
Queste informazioni inserite nel file di override saranno prese in considerazione solamente 
nella fase di inizializzazione / popolamento del DB.

Altre impostazioni
------------------

Nel file di override andremo anche a modificare le impostazioni relative a

- INSPIRE - di default non è abilitato
- Visualizzazione di default - "minimal" di solito, la imposteremo come "inspire"

==============================
Preparazione del CATALINA_BASE
==============================

Si copia prima di tutto lo scheletro della gerarchia di directory::

   cp -a /var/lib/tomcat/base/ /var/lib/tomcat/geonetwork

Modifica ``server.xml``
-----------------------

La configurazione di default prevede l’uso delle porte

- 8005 per lo shutdown
- 8080 per la connessione HTTP
- 8009 per AJP

Per GeoNetwork lasceremo inalterate queste porte di default (vedi anche :ref:`cerco_apache_port`).

GeoNetwork datadir
------------------

Creiamo quindi la directory ``/var/lib/tomcat/geonetwork/gn`` dove GeoNetwork gestirà i dati locali. 
All'interno di questa directory dovrà essere presente la gerarchia di directory attesa da GN;
scompattando il file http://demo.geo-solutions.it/share/cerco/gn/gn.tgz a partire dalla directory 
``tomcat/geonetwork`` si otterrà la gerarchia di directory richiesta::

   cd /var/lib/tomcat/geonetwork
   tar xzvf gn.tgz -C /var/lib/tomcat/geonetwork


Modifica ``setenv.sh``
----------------------

Nel file ``/var/lib/tomcat/geonetwork/bin/setenv.sh`` possono essere impostate delle variabili
d'ambiente e variabili di sistema che saranno poi usate nella JVM di geonetwork.

Qui imposteremo:

- variabili d'ambiente usate dallo script di tomcat per individuare la directory base (``CATALINA_BASE``)
- variabili di sistema usate dalla JVM per configurare la quantità di memoria usabile
- variabili di sistema per configurare il file di override di GeoNetwork
- variabili di sistema per configurare le directory dati di GeoNetwork

Si può usare questo il file a questa URL:
   http://demo.geo-solutions.it/share/cerco/gn/setenv.sh

Es.::

  # Set tomcat vars
  export CATALINA_BASE=/var/lib/tomcat/geonetwork
  export CATALINA_HOME=/opt/tomcat/  
  export CATALINA_PID=$CATALINA_BASE/work/pidfile.pid
  
  # Configure memory and system stuff   
  export JAVA_OPTS="$JAVA_OPTS -Xms1024m -Xmx2048m -XX:MaxPermSize=512m"
  export JAVA_OPTS="$JAVA_OPTS -Dorg.apache.lucene.commitLockTimeout=60000"

  # Configure GeoNetwork  
  export GN_EXT_DIR=$CATALINA_BASE/gn

  # Configure override file  
  export GN_OVR_PROPNAME=geonetwork.jeeves.configuration.overrides.file
  export GN_OVR_FILE=$GN_EXT_DIR/config-overrides-cerco.xml 
  export JAVA_OPTS="$JAVA_OPTS -D$GN_OVR_PROPNAME=$GN_OVR_FILE"
  
  #export JAVA_OPTS="$JAVA_OPTS -Dgeonetwork.dir=$GN_DATA_DIR"
  
  # Configure data dirs
  export GN_CTX=geonetwork.  
  export JAVA_OPTS="$JAVA_OPTS -D${GN_CTX}data.dir=$GN_EXT_DIR/data/metadata_data"
  export JAVA_OPTS="$JAVA_OPTS -D${GN_CTX}resources.dir=$GN_EXT_DIR/data/resources"
  export JAVA_OPTS="$JAVA_OPTS -D${GN_CTX}svn.dir=$GN_EXT_DIR/data/metadata_subversion"
  export JAVA_OPTS="$JAVA_OPTS -D${GN_CTX}lucene.dir=$GN_EXT_DIR/index"

Al file vanno impostati i permessi di esecuzione::

  chmod +x bin/setenv.sh


Modifica file di override
-------------------------

Come descritto precedentemente, nel file di override è possibile specificare alcune informazioni 
riguardanti il sito. Queste informazioni vanno editate nel file ``config-overrides-cerco.xml``.

Questo file dovrebbe essere già presente nella directory ``gn/`` se si è usato il file ``gn.tgz``.

Come descritto precedentemente, andremo ad editare:

- le entry relative al sito (sono le tre properties definite all’inizio del file),
- le credenziali di accesso al db
- i servizi WMS per le mappe di preview.

===============================
Configurazione avvio automatico
===============================

Creare il file ``/etc/init.d/geonetwork`` caricandolo da http://demo.geo-solutions.it/share/cerco/gn/geonetwork 
o inserendo il seguente contenuto::

  #!/bin/bash
  # tomcat       Start/Stop the tomcat server.
  # chkconfig:   2345 90 60
  # description: Tomcat script by GeoSolutions

  CATALINA_HOME=/opt/tomcat
  CATALINA_BASE=/var/lib/tomcat/geonetwork/
  prog="Apache Tomcat - GeoNetwork"

  USERNAME=tomcat

  start() {
      echo -n $"Starting $prog: "
      echo
      su - $USERNAME -s /bin/sh -c "$CATALINA_HOME/bin/startup.sh"
      return $?
  }
  restart() {
      stop
      sleep 5
      start
  }
  stop() {
      echo -n $"Stopping $prog: "
      echo
      su - $USERNAME -s /bin/sh -c "$CATALINA_HOME/bin/shutdown.sh -force"
      return $?
  }

  case "$1" in
    start)
      start
      ;;
    stop)
      stop
      ;;
    restart)
      restart
      ;;
    *)
      echo $"Usage: $0 {start|stop|restart}"
      exit 1
  esac

Una volta creato il file, impostarlo come file eseguibile ::

   chmod +x /etc/init.d/geonetwork

e configurare l’avvio automatico con ::

   chkconfig --add geonetwork

=======================
Configurazione watchdog
=======================

.. warning:: 
   ** TODO **

=============================
Impostazione database PostGIS
=============================

Da utente postgres, lanciare ``psql``::

   CREATE USER geonetwork LOGIN PASSWORD 'G30n3twroK' SUPERUSER INHERIT NOCREATEDB NOCREATEROLE;

Editare quindi il file ``/var/lib/pgsql/9.2/data/pg_hba.conf`` e permettere la connessione 
all'utente geonetwork tramite connessione TCP: aggiungere la riga ::

   host    all    geonetwork    127.0.0.1/32    md5

prima della riga ::

   host    all    all        127.0.0.1/32    ident

Per permettere l'accesso usando ``psql``, aggiungere la riga ::

   local    all    geonetwork                md5

prima di ::

   local    all    all                    peer

.. _gn_create_db:

Creazione del DB
----------------

Da shell::
   
   -bash-4.1$ createdb -O geonetwork  geonetwork
   -bash-4.1$ psql -W -U geonetwork -d geonetwork -c "CREATE EXTENSION postgis;"
   Inserisci la password per l'utente geonetwork:   
   CREATE EXTENSION
   -bash-4.1$ psql -W -U geonetwork -d geonetwork -c "CREATE EXTENSION postgis_topology;"
   Inserisci la password per l'utente geonetwork:
   CREATE EXTENSION
   -bash-4.1$ psql -W -U geonetwork -d geonetwork -f /usr/pgsql-9.2/share/contrib/postgis-2.0/legacy.sql


=========================
Configurazione GeoNetwork
=========================

Installazione web app
---------------------

Copiare il file .war in webapps::

   cp geonetwork.war /var/lib/tomcat/geonetwork/webapps/ 

Lanciare il servizio ::

   service geonetwork start

Questo lancerà tomcat, e ``geonetwork.war`` sarà espanso. 
Le variabili d'ambiente sono già impostate in ``setenv.sh``, per cui le customizzazioni effettuate tramite 
variabili d'ambiente e file di override sono già operative. 
Ciò che non è stato ancora effettuato è la customizzazione dei file interni a geonetwork.

Per far questo si deve espandare il file ``webapp_geonetwork.tgz``::

   tar xzvf /root/gn/webapps_geonetwork_update.tgz -C /var/lib/tomcat/geonetwork/webapps/

e rilanciare geonetwork.

Notare che, tra le customizzazione effettuate, c'è anche la posizione dei file di log: 
la prima esecuzione creerà dei file di log in ``/home/tomcat/logs/geonetwork.log`` mentre, 
una volta eseguita la customizzazione, i nuovi file saranno creati in ``/var/lib/tomcat/geonetwork/logs/``.

Se si desidera effettuare il patch di GN prima di lanciare il servizio, per evitare di passare 
per stati intermedi con la creazione di file di log temporanei:

- Espandere il file war manualmente ::

   cd /var/lib/tomcat/geonetwork/webapps/
   mkdir geonetwork
   cd geonetwork
   jar xvf /root/geonetwork-main-2.8.0.war

- quindi espandere il file ``webapp_geonetwork.tgz`` come specificato precedentemente.

Configurazione file di log
--------------------------

È possibile modificare le impostazioni di log nel file ``WEB-INF/log4j.cfg``.

Questo file viene già ridefinito nell'espansione di ``webapp_geonetwork.tgz``.
I valori così impostati dovrebbero essere corretti; controllare in ogni caso la posizione del file di log:
la riga dovrebbe presentarsi così::

   log4j.appender.jeeves.file = ${catalina.base}/logs/geonetwork.log

Fare particolare attenzione a che appaia ``${catalina.base}``. Il file di log dovrebbe in questo modo 
essere creato nella directory ``/var/lib/tomcat/geonetwork/logs/``.

Altre config
------------

- In ``WEB-INF/config.xml`` porre a "``false``" l'elemento ``/geonet/general/debug``.
- Assicurarsi che il contenuto del file ``javax.xml.transform.TransformerFactory`` sia quello qui sotto::

   [root@cerco geonetwork]# cat \ WEB-INF/classes/META-INF/services/javax.xml.transform.TransformerFactory
   de.fzi.dbs.xml.transform.CachingTransformerFactory


Configurazioni finali
---------------------

Una volta che tutti i file in ``/var/lib/tomcat/geonetwork/`` sono stati correttamente impostati, 
assicurarsi che l'ownership della directory sia assegnata all'utente tomcat::

   chown tomcat: -R /var/lib/tomcat/geonetwork/

======================================
Configurazione httpd: Proxy GeoNetwork
======================================

Per poter raggiungere GeoNetwork sulla porta 80 attraverso httpd, bisogna configurare un reverse proxing.

Creare il file ``/etc/httpd/conf.d/90geonetwork.conf``

e inserire le righe::

   ProxyPass        /geonetwork ajp://localhost:8009/geonetwork
   ProxyPassReverse /geonetwork ajp://localhost:8009/geonetwork

e quindi caricare la nuova configurazione con ::

    service httpd reload

Ora GeoNetwork dovrebbe essere raggiungibile all’indirizzo 
    http://84.33.2.27/geonetwork

Potrebbe essere necessario anche la disabilitazione del blocco SELinux alle connessioni interne richieste da httpd::

   setsebool httpd_can_network_connect 1

.. _gn_web_config:

=============================
Configurazione web GeoNetwork
=============================

Come detto in precedenza, parte delle impostazioni di GeoNetwork si effettuano da web.

Eseguire il login con le credenziali di default (admin / admin ).

Password di amministrazione
---------------------------

Entrare nella pagina di Amministrazione / Cambia password e modificare la password di default ``admin``.

Informazioni sul sito
---------------------

Entrare nella pagina di Amministrazione / Configurazione del sistema, e modificare le informazioni 
sul sito (nome del sito visto dall’esterno -- anche nei documenti CSW)

** ADD IMAGE HERE **

e il server

** ADD IMAGE HERE **

Logo
----

È possibile personalizzare il logo del sito dalla schermata di amministrazione.

Nel gruppo di opzioni "Configurazione del catalogo", selezionare "Configurazione del logo".
Caricare l’immagine che si vuole usare come logo. Una volta caricata, selezionarla e cliccare su "Usa per il catalogo".

Nelle versioni precedenti di GN si poteva usare solo la procedura non interattiva:
Si doveva individuare l'UUID del sito (dalla pagina di informazioni -- link "Info" sulla toolbar). 
Dopodiché si doveva copiare l'immagine gif del logo desiderato all'interno della directory ``images/logos``, 
con il nome ``UUID_del_sito.gif``.

==============================
Riconfigurazione su VM clonate
==============================

Per informazioni sulla clonazione di VM, seguire le istruzioni riportate sul documento :ref:`cerco_cloning_vm`.

I paragrafi seguenti mostrano solo come riconfigurare GeoNetwork su una VM clonata e riconfigurata correttamente.

Configurazioni di GeoNetwork da modificare
------------------------------------------

Configurazioni su file
``````````````````````

Layer per la mappa di ricerca
_____________________________

Modificare WMS server, layer e bounding box come descritto nella sezione di configurazione di GeoNetwork.

Configurazioni da webapp / DB
`````````````````````````````

Le configurazioni su DB includono anche la generazione automatica dell’UUID del sito.

Per essere sicuri di avere dati completamente puliti, conviene eliminare il DB esistente e crearne uno nuovo.

Fermare l'istanza di GeoNetwork
_______________________________

Poiché questa è un clone completo della macchina di partenza, GeoNetwork è impostato per partire automaticamente, 
ed andrà quindi fermato ::

   service geonetwork stop

Eliminare il DB
_______________
Da utente postgres ::

   dropdb geonetwork
   
Ricreare il DB
______________
Seguire i passi indicati nella sezione :ref:`gn_create_db`::

   createdb -O geonetwork  geonetwork
   psql -W -U geonetwork -d geonetwork -c "CREATE EXTENSION postgis;"
   psql -W -U geonetwork -d geonetwork -c "CREATE EXTENSION postgis_topology;"
   
Rilanciare GeoNetwork
_____________________
::

    service geonetwork start
    
Impostazioni
____________

Seguire i passi nella sezione :ref:`gn_web_config`.

=========================================
Configurazione del GeoNetwork su nodo hub
=========================================

.. warning::
      TODO 
      (harvesting dalla macchina di frontend alle varie province)

=======================
Istruzioni per il build
=======================

Per compilare da zero GeoNetwork 2.8, ottenere i sorgenti da https://github.com/geonetwork/core-geonetwork, 
usando il branch 2.8.x, dopodichè compilare con l'opzione INSIPRE in questo modo::

   mvn clean install -Penv-inspire


Checklist per la reinstallazione di GN
--------------------------------------

- backup webapp/geonetwork
- drop & recreate db
- setup new setenv.sh
- setup gn/
- edit override file
- copy new war
- fix log4j in war
- chown
- scompattare gn_custom.tgz


========
Versioni
========

+----------+------------+--------+--------------------------------------------------------+
| Versione | Data       | Autore | Note                                                   |
+==========+============+========+========================================================+
| 1.0      |            | ETj    | Versione iniziale                                      |
+----------+------------+--------+--------------------------------------------------------+
| 1.1      |            | ETj    | Modifiche riguardanti l’uso di GN2.8.0 invece di 2.6.4 |
+----------+------------+--------+--------------------------------------------------------+
| 1.2      | 2013-05-08 | ETj    | Revisione completa                                     |
+----------+------------+--------+--------------------------------------------------------+
| 1.3      | 2013-08-02 | ETj    | Porting su restructuredtext                            |
+----------+------------+--------+--------------------------------------------------------+
