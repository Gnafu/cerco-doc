.. _cerco_deploy_ckan:

#######################################
Installazione e configurazione CKAN 1.8
#######################################

Version 1.0 
22/07/2013

============
Introduzione
============

In questo documento sono esplicitate solo le informazioni per l'installazione di componenti specifici
per CKAN e relative estensioni.

Si presuppone che il sistema base sia già stato installato e configurato come descritto nel documento :ref:`cerco_setup_vm`, 
Su tale documento sono infatti descritte le procedure per l'installazione di alcuni componenti base del sistema, 
tipo PostgreSQL, Apache HTTPD, Oracle Java, ApacheTomcat.


==================
Installazione Solr
==================

Solr è una webapp java usata da CKAN come backend per le ricerche dei dataset.
Solr andrà installato in una istanza tomcat a parte per disaccoppiarne il più possibile il funzionamento 
con le altre webapp installate (GeoNetwork)

Andremo ad installare quindi la base di Solr in ``/var/lib/tomcat/solr``, e i relativi file di configurazione, 
analogamente a quanto fatto per GeoNetwork, in una subdir della stessa catalina base, ossia ``/var/lib/tomcat/solr/solr``.

Notare che le VM installate sono leggermente diverse in questo, in quanto Solr è installato nella stessa istanza tomcat 
di GeoNetwork, ed ha i file di configurazione e dati in ``/opt/solr``.

Scaricare solr e scompattare::

   mkdir /root/ckan
   cd /root/ckan
   wget http://archive.apache.org/dist/lucene/solr/1.4.1/apache-solr-1.4.1.tgz
   tar xzvf apache-solr-1.4.1.tgz

Creare la catalina base::

   cp -a /var/lib/tomcat/base/  /var/lib/tomcat/solr

Copiare file di configurazione e war ::

   cp -av /root/ckan/apache-solr-1.4.1/example/solr /var/lib/tomcat/solr
   cp -av /root/ckan/apache-solr-1.4.1/dist/apache-solr-1.4.1.war /var/lib/tomcat/solr/webapps/solr.war

Editare il file ``/var/lib/tomcat/solr/bin/setenv.sh``. 
Come per GeoNetwork, in questo file imposteremo alcune variabili d'ambiente utili a tomcat, alla JVM, ed alla webapp.

::

    export CATALINA_BASE=/var/lib/tomcat/solr
    export CATALINA_HOME=/opt/tomcat/
    export CATALINA_PID=$CATALINA_BASE/work/pidfile.pid

    export JAVA_OPTS="$JAVA_OPTS -Xms512m -Xmx800m -XX:MaxPermSize=256m"

    export JAVA_OPTS="$JAVA_OPTS -Dsolr.solr.home=$CATALINA_BASE/solr/"
    export JAVA_OPTS="$JAVA_OPTS -Dsolr.data.dir=$CATALINA_BASE/solr/data"
   
Modifica server.xml
-------------------

La configurazione di default prevede l'uso delle porte

- 8005 per lo shutdown
- 8080 per la connessione HTTP
- 8009 per AJP

Queste porte sono già configurate per l'istanza tomcat di geonetwork, per cui useremo:

- shutdown: 8006
- HTTP: 8081
- AJP: 8010

Vedere anche :ref:`cerco_apache_port`.


Configurazione avvio automatico
-------------------------------

Creare il file ``/etc/init.d/solr`` caricandolo da ``http://demo.geo-solutions.it/share/cerco/solr/solr``   
oppure copiando il file ``/etc/init.d/geonetwork`` e modificando le prime righe in::

   export CATALINA_BASE=/var/lib/tomcat/solr
   prog="Apache Tomcat - Solr

Una volta creato il file, impostarlo come file eseguibile ::

   chmod +x /etc/init.d/solr

e configurare l'avvio automatico con ::

   chkconfig --add solr

Configurazioni finali
---------------------

Assegnare la proprietà della directory ``solr/`` all'utente tomcat ::

   chown tomcat: -R /var/lib/tomcat/solr

========================================
Installazione pacchetti e configurazione
========================================

Installare i pacchetti necessari a CKAN::

   yum install python-devel libxml2-devel libxslt-devel python-babel python-psycopg2 python-lxml python-pylons python-repoze-who python-repoze-who-plugins-sa python-repoze-who-testutil python-repoze-who-friendlyform python-tempita python-zope-interface postgresql92-devel

================
Creazione utenti
================

Utente di sistema
-----------------

Creare l'utente di sistema ``ckan`` ::

    adduser ckan 

Impostare una password e annotarla  ::

    passwd ckan
    
=========================
Configurazione PostgreSQL
=========================

Creare l'utente ``ckan`` per postgres::

   su - postgres -c "createuser -S -D -R -P ckan"

Creare il db::

   su - postgres -c "createdb -O ckan ckan"

Abilitare il login di ckan da locale, editando il file ``/var/lib/pgsql/9.2/data/pg_hba.conf`` 
aggiungendo la linea::

   local   all             ckan                   md5

prima di ::

   local   all             all                     peer

Riavviare postgresql::

   service postgresql-9.2 restart

============================
Configurazione ambiente CKAN
============================

Installazione dipendenze python
-------------------------------

Da root eseguire::

   easy_install pip
   pip install virtualenv

Da utente ckan::

   $ cd
   $ virtualenv --no-site-packages ~/pyenv
   $ . pyenv/bin/activate
   (pyenv)$ pip install -e 'git+https://github.com/geosolutions-it/ckan.git@1.8_cerco#egg=ckan'
   $ git branch --track 1.8_cerco remotes/origin/1.8_cerco   
   Branch 1.8_cerco set up to track remote branch 1.8_cerco from origin.
   $ git checkout 1.8_cerco
   
   (pyenv)$ export PATH=$PATH:/usr/pgsql-9.2/bin/
   (pyenv)$ pip install -r pyenv/src/ckan/pip-requirements.txt
   (pyenv)$ cd pyenv/src/ckan
   (pyenv)$ pip install --ignore-installed -r requires/lucid_missing.txt -r requires/lucid_conflict.txt

   (pyenv)$ pip install webob==1.0.8
   (pyenv)$ pip install Distribute
   (pyenv)$ pip install --ignore-installed -r requires/lucid_present.txt

   (pyenv)$ deactivate

   $ . /home/ckan/pyenv/bin/activate
   (pyenv)$ paster make-config ckan development.ini

Configurazione Solr
-------------------

Configurare in Solr lo schema necessario a CKAN::

   service solr stop
   cd /var/lib/tomcat/solr/solr/conf
   mv schema.xml schema.xml.original
   cp /home/ckan/pyenv/src/ckan/ckan/config/solr/schema-1.4.xml schema.xml
   chown tomcat: schema.xml
   service solr start
   
Configurazioni ckan
-------------------

Modificare il file /home/ckan/pyenv/src/ckan/development.ini

- Parametri di connessione ::

    sqlalchemy.url: url al db CKAN: postgresql+psycopg2://ckan:PASSWORD@/ckan
    solr_url: http://127.0.0.1:8081/solr
- Dati del sito ::

    ckan.site_id:
    ckan.site_title:
    ckan.site_url:
- Notifiche mail (es.) ::

    email_to = info@progetto.cerco.it
    smtp_server = server.smtp.per.progetto.cerco.it
    error_email_from = notifiche@progetto.cerco.it

- Lingua ::

    ckan.locale_default = it
    ckan.locales_offered = it en es fr
    ckan.locale_order = it en es fr

- File di log ::

    ckan.log_dir = /home/ckan/log
    ckan.dump_dir = /home/ckan/dump
    ckan.backup_dir = /home/ckan/backup

    [handler_file]
    class = logging.handlers.RotatingFileHandler
    formatter = generic
    level = NOTSET
    args = ("/home/ckan/ckan.log", "a", 20000000, 9)


Inizializzazione dir
''''''''''''''''''''
::

   cd /home/ckan
   mkdir log dump backup
   
Inizializzazione DB
'''''''''''''''''''

Da utente ckan::

   cd pyenv/src/ckan/
   . ~/pyenv/bin/activate
   (pyenv)$ paster --plugin=ckan db init

Utenti CKAN
'''''''''''

Aggiungere utenti con profilo amministratore con il comando ::

   (pyenv)$ paster --plugin=ckan sysadmin add NOMEUTENTE
   
Aggiungere perlomeno gli utenti

- `admin`, da usare per login interattivo
- `harvest`, per gestione di backend

Primo avvio di CKAN
'''''''''''''''''''

Lanciare CKAN da linea di comando da utente ckan con ::

   (pyenv)$ paster serve development.ini &

===========================
Configurazione apache httpd
===========================

Da utente root, creare il file ``/etc/httpd/conf.d/92ckan.conf`` con il seguente contenuto::

   ProxyPass        / http://localhost:5000/
   ProxyPassReverse / http://localhost:5000/

e ricaricare la configurazione ::

   service httpd reload

SElinux
-------

`httpd` è limitato per default da SELinux ad effettuare connessioni TCP interne; 
per abilitare correttamente il proxying, dare il comando ::

   setsebool -P httpd_can_network_connect 1


===========================
Configurazione file storage
===========================

*FileStore* serve ad abilitare upload di dati in CKAN. La doc di riferimento è http://docs.ckan.org/en/latest/filestore.html.

Creare la directory ::

   mkdir -p /home/ckan/data/storage

*(la versione correntemente installata ha questi dati in ``/home/ckan/data``)*

Modificare la configurazione per lo storage nel file ``development.ini``::

   ckan.storage.bucket = bucket00
   ofs.impl = pairtree
   ofs.storage_dir = /home/ckan/data/storage

=======================
Installazione harvester
=======================

Install erlang
--------------

Da root eseguire::

   yum install erlang

Install rabbitmq
----------------

Installare rabbitmq come riportato su http://www.rabbitmq.com/install-rpm.html::

   rpm --import http://www.rabbitmq.com/rabbitmq-signing-key-public.asc
   wget http://www.rabbitmq.com/releases/rabbitmq-server/v3.1.0/rabbitmq-server-3.1.0-1.noarch.rpm
   yum install rabbitmq-server-3.1.0-1.noarch.rpm

Sostituire il file ``/etc/init.d/rabbitmq-server`` con il quello a 
   http://www.couyon.net/uploads/7/4/6/3/7463062/rabbitmq-server

Questo fa eseguire rabbitmq da utente non privilegiato, come riportato su questa pagina:
   http://www.couyon.net/1/post/2012/07/so-you-want-to-run-rabbitmq-on-rhelcentos-6.html

::

   wget http://www.couyon.net/uploads/7/4/6/3/7463062/rabbitmq-server
   cp rabbitmq-server /etc/init.d
   chmod +x /etc/init.d/rabbitmq-server
   chkconfig rabbitmq-server on
   service rabbitmq-server start

Installazione ckan harvester
----------------------------

Da utente ckan::

   cd /home/ckan/pyenv/src
   . ~/pyenv/bin/activate
   (pyenv)$ git clone https://github.com/geosolutions-it/ckanext-harvest.git
   (pyenv)$ cd ckanext-harvest
   (pyenv)$ git branch --track 1.8_cerco remotes/origin/1.8_cerco
   Branch 1.8_cerco set up to track remote branch 1.8_cerco from origin.
   (pyenv)$ git checkout 1.8_cerco
   Switched to branch 'release-v1.8'
   (pyenv)$ pip install -r pip-requirements.txt
   (pyenv)$ pip install lxml
   (pyenv)$ python setup.py develop
   (pyenv)$ cd /home/ckan/pyenv/src/ckan

Terminare il processo python di CKAN se attivato in precedenza e modificare nel file ``development.ini`` 
il parametro ``ckan.plugin``::

   ckan.plugins = stats harvest ckan_harvester

Inizializzare il database per l'harvester::

   paster --plugin=ckanext-harvest harvester initdb --config=development.ini

Script harvesting
-----------------

L'avvio della procedura di harvesting richiede un paio di chiamate da linea di comando. 
Per facilitare sia l'avvio manuale che l'harvest temporizzato, creare il file ``/home/ckan/harvest_hit.sh`` con contenuto::

   /home/ckan/pyenv/bin/paster --plugin=ckanext-harvest harvester job-all  --config=/home/ckan/pyenv/src/ckan/development.ini
   /home/ckan/pyenv/bin/paster --plugin=ckanext-harvest harvester run  --config=/home/ckan/pyenv/src/ckan/development.ini

Harvesting temporizzato
-----------------------

Aggiungere un cron job per l'harvester::

   crontab -e -u ckan

Inserire nel crontab la seguente linea per eseguire l'harvest ogni 15 minuti::

   */15 * * * * /home/ckan/harvest_hit.sh

=============================
Installazione ckanext-spatial
=============================

Il plugin *spatial* permette a CKAN di fare harvesting tramite CSW su metadati spaziali ISO19139.

Configurazione DB
-----------------

Come root, configurare il database ``ckandb``::

   # su - postgres -c "psql ckan"
   ckandb=# CREATE EXTENSION postgis;
   ckandb=# GRANT ALL PRIVILEGES ON DATABASE ckan TO ckan;
   ckandb=# GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ckan;

Installazione plugin
--------------------

Come utente ckan::

   . ~/pyenv/bin/activate
   (pyenv)$ cd /home/ckan/pyenv/src
   pip install -e git+https://github.com/geosolutions-it/ckanext-spatial.git#egg=ckanext-spatial
   cd ckanext-spatial

La repository è impostata per fornire automaticamente il ``branch 1.8_cerco``. 
Verificare con::

   $ git branch
   * 1.8_cerco

Se il branch corrente non dovesse essere corretto, selezionarlo con::

   git branch --track 1.8_cerco remotes/origin/1.8_cerco
   git checkout 1.8_cerco

Continuare l'installazione delle librerie richieste::

   (pyenv)$ pip install -r pip-requirements.txt


Inizializzazione DB spaziale
----------------------------

Inizializzazione del database, dove 4326 è lo SRID delle geometrie::

   (pyenv)$ cd /home/ckan/pyenv/src/ckan
   (pyenv)$ paster --plugin=ckanext-spatial spatial initdb 4326

Configurazione
--------------

Modificare nel file ``development.ini`` il parametro ckan.plugin aggiungendo i seguenti plugin::

   spatial_metadata spatial_query spatial_query_widget dataset_extent_map wms_preview cswserver spatial_harvest_metadata_api gemini_doc_harvester gemini_waf_harvester gemini_csw_harvester 

Nel file ``development.ini`` si può specificare lo SRID utilizzato::

   ckan.spatial.srid = 4326

La configurazione della validazione da effettuare durante l'harvesting::

   ckan.spatial.validator.profiles = iso19139,gemini2,constraints

Modificare con i dati del nodo la configurazione del server CSW::

   cswservice.title = CERCO - test node
   cswservice.abstract = Progetto CERCO - Nodo di test
   cswservice.keywords =
   cswservice.keyword_type = theme
   cswservice.provider_name = CERCO test node
   cswservice.contact_name = poc_nodo@progetto.cerco.it
   cswservice.contact_position =
   cswservice.contact_voice =
   cswservice.contact_fax =
   cswservice.contact_address =
   cswservice.contact_city =
   cswservice.contact_region =
   cswservice.contact_pcode =
   cswservice.contact_country =
   cswservice.contact_email =
   cswservice.contact_hours =
   cswservice.contact_instructions =
   cswservice.contact_role =
   cswservice.rndlog_threshold = 0.01
   cswservice.log_xml_length = 1000

Upgrade libxml2
---------------

Come riportato su https://github.com/okfn/ckanext-spatial:
    NOTE: The ISO19139 XSD Validator requires system library libxml2 v2.9 (released Sept 2012).

Per effettuare l'upgrade::

   wget ftp://ftp.pbone.net/mirror/ftp5.gwdg.de/pub/opensuse/repositories/X11:/Enlightenment:/EWebKit/CentOS_CentOS-6/x86_64/libxml2-2-2.9.0-93.1.x86_64.rpm
   rpm -U --force libxml2-2-2.9.0-93.1.x86_64.rpm

Modifica config Solr
--------------------

Da root impostare il valore di ``maxBooleanClauses`` a 16384 nel file ``/var/lib/tomcat/solr/solr/conf/solrconfig.xml``
e infine riavviare Solr::

   service solr restart

==============================
Installazione plugin DataStore
==============================

Il plugin DataStore dovrebbe evitare l'uso del dataproxy esterno 
(vedi email http://lists.okfn.org/pipermail/ckan-discuss/2013-March/002593.html).

Documentazione sull'installazione: http://docs.ckan.org/en/latest/datastore-setup.html

Configurazione DB
-----------------

Come utente postgres::

   createuser -S -D -R -P -l ckanreadonly
   
(annotare la password scelta) 

Aggiungere la seguente linea al file ``/var/lib/pgsql/9.2/data/pg_hba.conf``::

   local    all    ckanreadonly    md5

Creare il db ``datastore``::

   createdb -O ckan datastore -E utf-8
   psql datastore
   datastore=# GRANT ALL PRIVILEGES ON DATABASE datastore TO ckan;
   datastore=# GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ckan;

Configurazione .ini
-------------------

Modificare nel file di configurazione di CKAN ``development.ini`` le seguenti proprietà::

   ckan.plugins = datastore
   ckan.datastore.write_url = postgresql+psycopg2://ckan:PW_CKAN@/datastore
   ckan.datastore.read_url = postgresql+psycopg2://readonlyuser:PW_READONLYUSER@/datastore

Come utente ckan eseguire::

   (pyenv)$ paster datastore set-permissions postgres

Verrà chiesta la password di sistema di ckan per sudo e poi la password dell'utente postgres del database.

Durante la fase di inizializzazione il plugin datastore controlla i messaggi di errore provenienti da PostgreSQL.
Nel caso nel sistema la lingua italiana sia il default, occorre modificare il file ``ckanext/datastore/plugin.py`` 
sostituendo le due stringhe "``permission denied``" con "``permesso negato``". 
In seguito alla modifica occorre rimuovere il file ``ckanext/datastore/plugin.pyc``.

Infine riavviare CKAN tramite il servizio ``supervisord``.

===================
Aggiornamento label
===================

CKAN usa il concetto di "gruppo" per gestire le autorizzazioni su vari sotto insiemi di dataset. 
Questi gruppi sono anche usati come categorizzazioni, e come tali è possibile avere criteri di ricerca basati sui gruppi.

Nel contesto CERCO non interessa il controllo di autorizzazione, per cui questa funzionalità è usata esclusivamente 
per fini di ricerce e categorizzazione; l'uso del termine "categoria" invece di "gruppo" rende più chiara questa funzionalità.

Per effettuare le modifiche nel file di localizzazione sono stati dati i comandi elencati qui di seguito. 
Notare che questi comandi **non** devono essere eseguiti, perchè i file così modificati sono già presenti nella repository github. 
Questi comandi sono qui documentati solo come riferimento.

::

   $ . pyenv/bin/activate
   (pyenv)$ cd pyenv/src/ckan
   (pyenv)$ sed -i "s/il gruppo/la categoria/g;s/un gruppo/una categoria/g;s/del gruppo/della categoria/g;s/questo gruppo/questa categoria/g;s/questi gruppi/queste categorie/g;s/nel gruppo/nella categoria/g;s/Un gruppo/Una categoria/g;s/i gruppi/le categorie/g;s/gruppi di utenti/categorie/g;s/un nuovo gruppo di utenti/una nuova categoria/g;s/Nuovo gruppo di utenti/Nuova categoria/g;s/creare gruppi/creare categorie/g;s/, gruppi,/, categorie,/g" ckan/i18n/it/LC_MESSAGES/ckan.po
   (pyenv)$ python setup.py compile_catalog --locale it

   running compile_catalog
   851 of 851 messages (100%) translated in 'ckan/i18n/it/LC_MESSAGES/ckan.po'
   compiling catalog 'ckan/i18n/it/LC_MESSAGES/ckan.po' to 'ckan/i18n/it/LC_MESSAGES/ckan.mo'

==========================
Configurazione supervisord
==========================

CKAN non fornisce script di default per l'avvio e il blocco; si dovrà quindi usare il demone supervisord a tale scopo.

Da root::

   yum install supervisor
   chkconfig supervisord on

Aggiungere al file ``/etc/supervisord.conf`` le seguenti istruzioni per gestire CKAN::

   [program:ckan]
   command=/home/ckan/pyenv/bin/paster serve /home/ckan/pyenv/src/ckan/development.ini
   user=ckan
   autostart=true
   autorestart=true
   numprocs=1
   log_stdout=true
   log_stderr=true
   stdout_logfile=/home/ckan/log/ckan_out.log
   stderr_logfile=/home/ckan/log/ckan_err.log
   logfile=/home/ckan/log/ckan_supervisord.log
   startsecs=10
   startretries=3

Aggiungere le seguenti istruzioni per CKAN Harvester::

   [program:ckan_gather_consumer]
   command=/home/ckan/pyenv/bin/paster --plugin=ckanext-harvest harvester gather_consumer --config=/home/ckan/pyenv/src/ckan/development.ini
   user=ckan
   autostart=true
   autorestart=true
   numprocs=1
   log_stdout=true
   log_stderr=true
   stdout_logfile=/home/ckan/log/ckan_gather_out.log
   stderr_logfile=/home/ckan/log/ckan_gather_err.log
   logfile=/home/ckan/log/ckan_gather_supervisord.log
   startsecs=10
   startretries=3

   [program:ckan_fetch_consumer]
   command=/home/ckan/pyenv/bin/paster --plugin=ckanext-harvest harvester fetch_consumer --config=/home/ckan/pyenv/src/ckan/development.ini
   user=ckan
   autostart=true
   autorestart=true
   numprocs=1
   log_stdout=true
   log_stderr=true
   stdout_logfile=/home/ckan/log/ckan_fetch_out.log
   stderr_logfile=/home/ckan/log/ckan_fetch_err.log
   logfile=/home/ckan/log/ckan_fetch_supervisord.log
   startsecs=10
   startretries=3

Avviare supervisord::

   /etc/init.d/supervisord start


=========================
Configurazione harvesting
=========================

Una volta impostate le varie applicazioni, si possono inserire in CKAN gli entrypoint su cui fare harvesting. 
Come da documento architetturale, le istanze di CKAN su nodi e su hub andranno ad eseguire l'harvesting su sorgenti diverse.

Per la configurazione dell'harvesting fare riferimento a :ref:`cerco_ckan_harvesting`, e più in particolare:

- :ref:`ckan_harvesting_partner`
- :ref:`ckan_harvesting_hub`


.. _config_tolomeo_ckan:

======================
Configurazione Tolomeo
======================

In questa sezione sono mostrati i punti di integrazione di CKAN con Tolomeo.

Le informazioni per l'installazione di Tolomeo si trovano nel documento :ref:`cerco_deploy_tolomeo`.

Configurazione CKAN per Tolomeo
-------------------------------

È sufficiente inserire le seguenti configurazioni nel file ``development.ini`` per integrare Tolomeo 
all'interno dell'installazione di CKAN ::

   #TOLOMEO configuration
   tolomeo.wmspreset=CercoFI
   tolomeo.base=/tolomeo
  
- ``tolomeo.wmspreset`` indica il preset di default da usare nella visualizzazione delle risorse WMS
- ``tolomeo.base`` indica il context sul quale è installato tolomeo


Customizzazione del viewer per il bounding box
----------------------------------------------

L'estensione spaziale di CKAN non permette una customizzazione fina sulle preview (layer di sfondo etc). 
Per personalizzare è quindi necessario andare a intervenire sul codice javascript.

Il file da modificare è 
    ``ckanext-spatial/ckanext/spatial/public/ckanext/spatial/js/dataset_map.js``

Questo file genera la mappa di default (con openStreetMap) e alternativamente una che utilizza 
un layer wms inglese, che è possibile modificare.

::

   #riga 82

   } else if (this.map_type=='os') {
              var copyrightStatements = "Contains Ordnance Survey data (c) Crown copyright and database right  [2012] <br>" + "Contains Royal Mail data (c) Royal Mail copyright and database right [2012]<br>" + "Contains bathymetry data by GEBCO (c) Copyright [2012]<br>" + "Contains data by Land & Property Services (Northern Ireland) (c) Crown copyright [2012]";
              // Create a new map
              var layers = [
                new OpenLayers.Layer.WMS("Geoserver layers - Tiled",
                    'http://osinspiremappingprod.ordnancesurvey.co.uk/geoserver/gwc/service/wms', {
                   LAYERS: 'InspireETRS89',
                   STYLES: '',
                   format: 'image/png',
                   tiled: true
                      }, {
                   buffer: 0,
                   displayOutsideMaxExtent: true,
                   isBaseLayer: true,
                   attribution: copyrightStatements,
                   transitionEffect: 'resize'
                  }
                )
              ];

   //..altro codice da customizzare riguardo la proiezione etc...
   

una volta modificato è necessario aggiungere alla configurazione di CKAN (file ``development.ini``) la riga ::

   ckan.spatial.dataset_extent_map.map_type = os

Ulteriori informazioni a https://github.com/geosolutions-it/ckanext-spatial#configuration---dataset-extent-map


==========================
Customizzazione UI di CKAN
==========================

Struttura directory
-------------------

Tutti i file riguardanti CKAN si trovano nella directory
    ``/home/ckan/pyenv/src/``

Qui sono presenti diverse subdir:

- ckan: applicazione CKAN principale
- ckan-harvest: estensione CKAN per l'harvesting
- ckan-spatial: estensione CKAN per la gestione di CSW e ISO19139
- geoalchemy: libreria python per la gestione del DB
- vdm: libreria python per il versioning
- eventuali altre subdir presenti sono backup di vecchie versioni.


Per la customizzazione della GUI si andranno a modificare i soli file dentro ckan/

Librerie
--------

Il motore di templating di ckan 1.8 è **Genshi** (http://genshi.edgewall.org/). 
Si rimanda alla documentazione specifica per quello che riguarda l'utilizzo del codice python all'interno delle pagine.

CKAN utilizza **twitter Bootstrap** http://twitter.github.io/bootstrap/ . 
In particolare la classe "row" è descritta a questa pagina : http://twitter.github.io/bootstrap/scaffolding.html

Definizione CSS
---------------

Nel file ``development.ini`` è presente la riga ::

   ckan.template_head_end = <link rel="stylesheet" href="/css/cerco.css" type="text/css">

Questa consente di inserire testo extra in fondo al nodo ``<head>`` dell'html.

Ciò significa che il file 
    ``/home/ckan/pyenv/src/ckan/ckan/public/css/cerco.css``

sarà aggiunto per ultimo e può fare overriding dello stile predefinito di CKAN.

Le customizzazioni allo stile sono state inserite tutte in questo file.

Logo
----

Il logo del sito e la favicon sono impostati dalle seguenti proprietà di ``development.ini``::

   ckan.site_logo = /img/logo_64px_wide.png
   ckan.favicon = /images/icons/ckan.ico

Tutti i file inseriti nella cartella 
    ``/home/ckan/pyenv/src/ckan/ckan/public``

saranno esposti sul web (ad esempio site_logo e favicon)

Templating
----------

Il framework usa il pattern MVC.

I controller sono in ``/home/ckan/pyenv/src/ckan/ckan/controllers/``.

I template per il rendering sono in ``/home/ckan/pyenv/src/ckan/ckan/templates/``.

I template delle pagine sono annidati a seconda della pagina che si prende in esame. I più interessanti ai nostri scopi sono:

- ``layout.html``:             definizione dei namespace
- ``layout_base.html``:        template di base per la costruzione della pagina
- ``home/``
   - ``index.html``:           home page
   - ``about.html``:           pagina di about
- ``snipplets/``               frammenti di html usati in diverse pagine
   - ``package_list.html``:    lista dei dataset (utilizzata nella ricerca)
- ``package/``                 (contiene tutti i template per i contenuti)
   - ``read_core.html``:       pagina del dataset
   - ``resource_read.html``:   pagina della risorsa


L'home page (``templates/home/index.html``) è stata costruita in maniera da avere un layout adattivo, 
in presenza o meno di categorie, quindi, qualora si voglia mantenere questa elasticità di comportamento,
verificare il comportamento del layout con e senza categorie inserite nel sistema.

Note implementative
-------------------

E' possibile avere una visione complessiva del sistema osservando i vari controller. 
L'esempio più semplice è ``HomeController`` (``pyenv/src/ckan/ckan/controllers/home.py``).

Qui si può vedere come il template utilizzato per l'"about" è ``home/about.html`` (sotto la directory ``ckan/templates``)::

   def about(self):
      return render('home/about.html')
      
Ulteriori dettagli
''''''''''''''''''

Il metodo ``render`` è definito in ``pyenv/src/ckan/lib/base.py``; 
questo include tramite la direttiva ``<xi:include href="...">`` il file ``layout.html``: questo è 
sostanzialmente un wrapper per ``../layout.html`` (contiene soltanto la direttiva ``include``) 
e quest'ultimo a sua volta include ``layout_base.html`` (layout di base utilizzato per la maggior parte 
delle pagine di CKAN). 

Questa struttura di inclusioni si ripete sostanzialmente identica per molti componenti dell'applicazione.

Esempi
______

Nei template è possibile trovare codice come questo (dal file ``home/index.html``)::

   <py:for each="pkg in c.recently_changed_packages">
      <h3 style="margin-bottom:0px" >
             <a href="${h.url_for(controller='package', action='read',        
                id=pkg['name'])}">${pkg['title']}</a></h3>

Per quanto riguarda le strutture di controllo, ossia ``<py:for each``, si faccia riferimento 
alla documentazioni di genshi (http://genshi.edgewall.org/wiki/Documentation/0.6.x/xml-templates.html).

Le informazioni relative ai dati disponibili al template (es: ``c.recently_changed_packages``) 
devono essere cercate all'interno del controller relativo, che usa l'oggetto ``c`` per passare tutte 
le informazioni usabili dal template. 

In questo caso si tratta di ``controllers/home.py``, metodo ::

   def index(self):
   
   
Pagine statiche
---------------

Per l'aggiunta di pagine statiche seguire l'esempio di license e about nel controller ``pyenv/src/ckan/ckan/controllers/home.py``.

Es.: aggiungiamo una pagina statica mappata su ``/progetto``.

#. Creiamo la pagina statica ``home/progetto.html``.
#. Andiamo ad editare la pagina ``ckan/templates/home/index.html`` e aggiungiamo::

     <a href="${h.url_for('/progetto')}"  title="progetto cerco" ><img src="/img/progetto_cerco.jpg" /></a>

   La pagina andrà a fornire un link a ``/progetto``, indirizzo da configurare.    
#. Nel controller ``ckan/controllers/home.py`` andiamo ad aggiungere::

    def progetto(self):
        return render('home/progetto.html')
        
#. Andiamo quindi a configurare il link ``/progetto``, dicendo al sistema quale controller e metodo andare a chiamare
   Editare il file ``ckan/config/routing.py`` ed aggiungere la riga::
   
      map.connect('progetto', '/progetto', controller='home', action='progetto')

========
Versioni
========

+----------+------------+--------+-----------------------------+
| Versione | Data       | Autore | Note                        |
+==========+============+========+=============================+
| 1.0      | 2013-07-23 | ETj    | Versione iniziale           |
+----------+------------+--------+-----------------------------+
| 1.2      | 2013-08-02 | ETj    | Porting su restructuredtext |
+----------+------------+--------+-----------------------------+

