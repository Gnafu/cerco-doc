.. _cerco_setup_vm:

#########################################
Configurazione VM e installazione SO base
#########################################

Version 1.3
22/07/2013

=================================
Configurazione di base VM / recap
=================================

Installata una macchina virtuale sul server ESX all’indirizzo 84.33.1.167 (demo3.geo-solutions.it)

Risorse assegnate alla VM:

- Spazio disco: 20GB
- RAM: 4GB
- Processore: 1 CPU da 2 core.

La configurazione data è sufficiente per una installazione di GeoNetwork dimostrativa contenente qualche centinaio di metadati.

Immagini ISO di partenza da cui installare il sistema operativo:

- http://mi.mirror.garr.it/mirrors/CentOS/6.3/isos/x86_64/CentOS-6.3-x86_64-bin-DVD1.iso
- http://mi.mirror.garr.it/mirrors/CentOS/6.3/isos/x86_64/CentOS-6.3-x86_64-bin-DVD2.iso 

Durante l’installazione di CentOS è stato effettuato il partizionamento automatico dell’hard disk (500MB per la partizione di /boot ed il resto allocato come disco logico LVM).

La rete virtuale è impostata come "bridged network" per permettere alla VM di ricevere richieste di connessione dall’esterno.

Host info
---------

Informazioni riassuntive del nodo installato:

- Hostname: cerco
- Indirizzo IP: 84.33.2.27
- Utenti
   - root / ******** (impostato all'installazione)
   - tomcat / ******** (vedi "Creazione utenti")
- Applicazioni installate
   - GeoNetwork 
      - http://84.33.2.27/geonetwork 
      - admin / ********

Installazione VM
----------------

Nell'installazione della VM ci porremo nel caso più generico possibile. 
Questo significa che non si daranno informazioni a VMWare sul tipo di SO installato, altrimenti alcuni passi 
dell’installazione saranno nascosti, rendendo l’installazione sulla VM diversa da una installazione su macchina reale.

Impostazioni VMWare
'''''''''''''''''''

Impostazioni per la creazione della macchina virtuale:

- VM configuration: Custom
- HW compatibility: workstation 8
- Install OS from: I will install the the operationg system later
- Guest OS: Linux Centos 64-bit
- VM name: impostare name e path a piacere
- Processors: 1 processore, 2 core
- Memory: 4096MB
- Network connection: bridged

Per la configurazione disco procedere come si preferisce.

Un esempio potrebbe essere:

- I/O Controller type: LSI Logic
- Disk: create a new virtual disk
- Virtual disk type: SCSI
- Mode: Independent, persistent
- Max disk size: 20G, store virtual disk as a single file.


Alla fine della configurazione della VM, configurare il lettore DVD impostando l’immagine del DVD1. Avviare quindi la VM.

========================
Installazione CentOS 6.3
========================

All’avvio dell'installer, selezionare "Install or upgrade an existing system"
 - Controllare l'integrità dell’immagine se si vuole, altrimenti premere "skip"
 - Next (presentazione del SO)
 - Selezionare lingua
 - Selezionare tastiera
 - Selezionare il tipo di dispositivo seguendo i suggerimenti a video (probabilmente "Dispositivi di storage di base")
 - Warning per il dispositivo di storage; se siamo su VM, sarà sicuramente vuoto, quindi procediamo con "Si,cancella i dati"
 - Nome host: specificare un nome o lasciare quello di default
 - *Si possono specificare ora le impostazioni di rete della macchina (bottone "configura rete"), 
   o si potrà fare successivamente da linea di comando.*
 - Indicare la città per selezionare il fuso orario
 - Inserire la password per root
 - tipo di installazione: "Utilizza tutto lo spazio".
    - Se si ha bisogno di una struttura particolare, selezionare "Crea layout personalizzato" 
      e procedere con le relative schermate.
 - OK a "Scrivi i cambiamenti su disco"
 - Profilo di software "Minimal", personalizza più avanti.

La procedura di installazione continuerà in automatico, fino alla richiesta di riavvio della macchina.

=========================
Configurazione di sistema
=========================

Nodo partner
------------

+-----------+-----------------+-----------------+-----------------------+
|           | Sistema di test | Produzione      | Produzione            |
|           |                 | (config minima) | (config raccomandata) |
+===========+=================+=================+=======================+
| CPU       | 1 CPU / core    | 4 CPU / core    | 4-8 CPU / core        |
+-----------+-----------------+-----------------+-----------------------+
| RAM       | 4 GB            | 4 GB            | 8 GB                  |
+-----------+-----------------+-----------------+-----------------------+
| Hard disk | 20 GB           | 20 GB           | 20-40 GB              |
+-----------+-----------------+-----------------+-----------------------+

Hub
---

+-----------+-----------------+-----------------+-----------------------+
|           | Sistema di test | Produzione      | Produzione            |
|           |                 | (config minima) | (config raccomandata) |
+===========+=================+=================+=======================+
| CPU       | 1 CPU / core    | 8 CPU / core    | 8 CPU / core          |
+-----------+-----------------+-----------------+-----------------------+
| RAM       | 4 GB            | 8 GB            | 16 GB                 |
+-----------+-----------------+-----------------+-----------------------+
| Hard disk | 20 GB           | 20 GB           | 60 GB                 |
+-----------+-----------------+-----------------+-----------------------+


======================
Configurazione di rete
======================

Editare il file ``/etc/sysconfig/network-scripts/ifcfg-eth0``, in particolare::

   BOOTPROTO="static"
   ONBOOT="yes"
   IPADDR=84.33.2.27
   NETMASK=.......
   GATEWAY=.......

Editare il file ``/etc/resolv.conf`` e aggiungere i nameserver assegnati.

Nella VM in oggetto, il file ha queste linee::

   nameserver 84.33.0.251
   nameserver 217.70.159.234
   nameserver 217.70.159.99
   nameserver 84.33.192.2

Avviare il servizio di rete::

   service network start

Controllare la connessione effettuando un ping ad un server esterno::

   ping google.com

Notare che in CentOS6 di default sono disabilitate le connessioni verso l'interno, che non siano verso il servizio ssh. 
Nella sezione relativa a httpd si possono trovare indicazioni su come abilitare il traffico in ingresso.

==========================
Installazione sistema base
==========================

Sincronizzazione orologio interno
---------------------------------

Installare il programma per la sincronizzazione da server ntp::

   yum install ntp

Editare il file ``/etc/ntp.conf`` ed aggiungere prima delle righe ``server`` la linea::

   server tempo.ien.it     # Galileo Ferraris

Sincronizzare l’ora del server con::

   service ntpdate start


Altre utility
-------------

Installare::

  yum install man
  yum install vim
  yum install openssh-clients         # serve anche per scp entranti
  yum install mc             # mc (con zip) è utile per navigare all’interno dei war
  yum install zip unzip


==================================
Installazione PostgreSQL e PostGIS
==================================

GeoNetwork necessita di un DB di backend. I DBMS supportati sono PostgreSQL, MySQL, Oracle, McKoi.

.. note::
  GeoNetwork permette di effettuare ricerche con filtri spaziali. Per far questo può utilizzare, se installate,
  le funzionalità spaziali offerte da PostGIS, estensione di PostgreSQL. 
  In mancanza di PostGIS, GeoNetwork implementa internamente i filtri spaziali, usando uno ShapeFile come 
  indice spaziale. Le performance offerte da PostGIS sono molto migliori di quelle ottenute tramite shapefile.

Installazione
-------------

Aggiornamento della lista dei pacchetti::

  yum check-update
  yum install wget

Installare il pacchetto della repository da cui verrà scaricato postgresql::

  curl -O http://yum.postgresql.org/9.2/redhat/rhel-6-x86_64/pgdg-centos92-9.2-6.noarch.rpm
  rpm -ivh pgdg-centos92-9.2-6.noarch.rpm

La repository EPEL 6 serve per i pacchetti GDAL::

  curl -O http://mirror.i3d.net/pub/fedora-epel/6/x86_64/epel-release-6-8.noarch.rpm
  rpm -ivh epel-release-6-8.noarch.rpm

Installazione::

  yum install postgresql92-server postgis2_92

Verifica::

  [root@cerco ~]# rpm -qa | grep postg
  postgresql-libs-8.4.13-1.el6_3.x86_64
  postgresql92-9.2.2-1PGDG.rhel6.x86_64
  postgresql92-server-9.2.2-1PGDG.rhel6.x86_64  
  postgresql92-libs-9.2.2-1PGDG.rhel6.x86_64
  postgis2_92-2.0.2-1.rhel6.x86_64
  [root@cerco ~]#

Inizializzazione del DB::

  service postgresql-9.2 initdb

Configurare l’avvio automatico con ::

  chkconfig --level 2345 postgresql-9.2 on
  chkconfig --add postgresql-9.2

Avvio del servizio ::

  service postgresql-9.2 start


Creazione template postgis
--------------------------

.. note:: 
   Da PostGIS 2.x la creazione di DB postgis è molto semplificata, così creare un template apposito è in pratica inutile.

   Di seguito lasciamo le info nel caso si dovesse usare una versione di PostGIS precedente.

Da utente posqlgres creare il template::

  createdb template_postgis
  createlang plpgsql template_postgis

  psql -d  template_postgis -f /usr/pgsql-9.2/share/contrib/postgis-2.0/postgis.sql

Quindi, entrando in psql::

  postgres=# update pg_database set datallowconn=false, datistemplate=true  where datname='template_postgis';
  UPDATE 1


================
Creazione utenti
================

Utente tomcat
-------------
:: 

  [root@cerco ~]# adduser -m -s /bin/bash tomcat
  [root@cerco ~]# passwd tomcat


==========================
Installazione apache httpd
==========================

Apache httpd è usato come entry point per le richieste web.

In particolare, sarà usato per fare reverse proxing delle chiamate verso geonetwork.

Installazione::

    yum install httpd

Configurare il ``ServerName`` in ``/etc/httpd/conf/httpd.conf``.

L'indirizzo IP assegnato a questa VM non è legato a nessun nome, per cui si imposta il servername all'indirizzo IP corrente::

  ServerName 84.33.2.27:80

Configurare l’avvio automatico con ::

  chkconfig --level 2345 httpd on

Avviare quindi il servizio con ::

  service httpd start

Si può controllare se dall'esterno la macchina risulti raggiungibile puntando il browser su 

  http://84.33.2.27

Configurazione traffico in ingresso
-----------------------------------

Se la macchina non fosse raggiungibile dall'esterno, abilitare i pacchetti in entrata con il comando::

  iptables -I INPUT -p tcp --dport 80 -j ACCEPT

e salvare la configurazione (in modo che al riavvio non si perda questa configurazione) con ::

  service iptables save
  
Configurazione httpd
--------------------

Abilitazione compressione gz
''''''''''''''''''''''''''''

Creare il file ``/etc/httpd/conf.d/05deflate.conf`` con il seguente contenuto::

  SetOutputFilter DEFLATE
  AddOutputFilterByType DEFLATE text/html text/plain text/xml text/javascript text/css

==================
Installazione java
==================

La pagina da dove si può scaricare il JDK è

  http://www.oracle.com/technetwork/java/javase/downloads/index.html

Oracle non mette a disposizione URL per lo scaricamento automatico del JDK in quanto è richiesta 
una accettazione interattiva della licenza. 
Si può iniziare a scaricare in locale l’RPM del JDK, e poi usare la URL di scaricamento sul server, 
usando il comando ``wget``, oppure scaricare in locale e poi copiare sul server tramite ``scp``.

::

  rpm -ivh jdk-7u11-linux-x64.rpm

Ignorare gli eventuali errori del tipo ::

  Error: Could not open input file: /usr/java/jdk1.7.0_11/jre/lib/rt.pack

Verificare che la jdk sia stata correttamente installata::

  # java -version
  java version "1.7.0_11"
  Java(TM) SE Runtime Environment (build 1.7.0_11-b21)
  Java HotSpot(TM) 64-Bit Server VM (build 23.6-b04, mixed mode)
  # javac -version
  javac 1.7.0_11

.. _cerco_deploy_tomcat:

====================
Installazione tomcat
====================

Scaricare apache tomcat e installarlo in ``/opt``::

  wget http://mirror.nohup.it/apache/tomcat/tomcat-6/v6.0.36/bin/apache-tomcat-6.0.36.tar.gz
  tar xzvf apache-tomcat-6.0.36.tar.gz -C /opt/

Si usa un link simbolico per semplificare eventuali upgrade::

  ln -s /opt/apache-tomcat-6.0.36/ /opt/tomcat

Creazione della directory modello `base/`
-----------------------------------------

::

  mkdir -p /var/lib/tomcat/base/{bin,conf,logs,temp,webapps,work}
  cp /opt/tomcat/conf/* /var/lib/tomcat/base/conf/

.. _cerco_apache_port:

========================
Web application previste
========================

Sono previste un totale di tre web application java in ogni nodo CERCO: GeoNetwork, Tolomeo, Solr (necessario per CKAN). 
Sebbene nei nodi poco trafficati queste webapp possano essere installate sotto un'unica istanza di Apache Tomcat, 
si potrebbe desiderare di avere istanze separate di tomcat, una per ogni webapp. 
Poichè ogni istanza deve avere il proprio set di porte in ascolto, proponiamo qui di seguito 
una tabella riassuntiva con le porte da assegnare ad ogni webapp:

+--------------+----------+------+------+
| webapp/porta | Shutdown | HTTP | AJP  |
|              |          |      |      |
+==============+==========+======+======+
| GeoNetwork   | 8005     | 8080 | 8009 |
+--------------+----------+------+------+
| Solr         | 8006     | 8081 | 8010 |
+--------------+----------+------+------+
| Tolomeo      | 8007     | 8082 | 8011 |
+--------------+----------+------+------+

Queste porte andranno configurate in:

#. nel file ``conf/server.xml`` dell'istanza tomcat, per indicare a tomcat quali porte usare per i tre servizi
#. nei file di configurazione di Apache HTTPD, per indicare nelle impostazioni del proxy dove trovare la webapp da pubblicare.

Informazioni specifiche saranno comunque fornite nelle relative sezioni di installazione di ogni singola webapp.

.. _cerco_cloning_vm:

=============================
Copia della macchina virtuale
=============================

Una volta che il SO e gli applicativi sono stati installati, potrebbe essere utile clonare la VM 
in modo da poter riutilizzare l'installazione in altri nodi.

Copia del disco virtuale e della VM
-----------------------------------

`Documentazione VMWare di riferimento <http://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=1027876>`_.

Accedere in ssh alla macchina host.

Entrare nella directory del datastore dove si trova la VM da clonare ::

   cd /vmfs/volumes/datastore1

Creare la directory per la nuova VM (es.) ::

   mkdir CERCO-fi

Copiare il disco virtuale ::

   vmkfstools -i CERCO/CERCO.vmdk CERCO-fi/CERCO-fi.vmdk

Entrare nel client vmware e creare una nuova VM, con i parametri suggeriti qui sotto.

I parametri possono essere modificati alla bisogna; ovviamente quello che non può essere modificato è 
la selezione del disco virtuale: 

- Configuration → custom
- Hardware compatibility → workstation 8.0
- Guest Operating System → Linux, CentOS 4/5/6 (64-bit)
- Name: CERCO-fi
- Processors / cores → 1 / 2
- Memory → 2048MB
- Named Network → VM Network
- I/O Controller types → LSI Logic
- Disk → Use an existing virtual disk
- Existing Disk File → selezionare il file CERCO-fi.vmdk appena creato

Creata la VM, il sistema creerà anche la directory ``CERCO-fi_2/`` contenente le impostazioni della VM.

Configurazioni di sistema da modificare
---------------------------------------

Una volta creata la VM, lanciarla.

A questo punto abbiamo una VM esattamente uguale all'originale. In particolare sarà uguale anche 
l'indirizzo IP, per cui quell'indirizzo può dare conflitti, ed è quindi una delle prime cosa da modificare.

Modifica impostazioni di rete
'''''''''''''''''''''''''''''

Entrare nella console dal client VMWare. Non si può usare ssh in quanto l'indirizzo IP al momento è usato 
sia dalla VM originale che da quella appena clonata.

Nella nuova VM l'indirizzo MAC della rete è cambiato, per cui si dovrà configurare a mano quello nuovo.

Il file ``/etc/udev/rules.d/70-persistent-net.rules`` contiene regole per l'assegnazione del nome 
del dispositivo (``ethN``) basandosi sul MAC address.

Questo file deve essere rimosso; sarà ricreato automaticamente al prossimo riavvio con le impostazioni corrette::

   mv /etc/udev/rules.d/70-persistent-net.rules /root/bk_udev_net

Trovare il MAC address della scheda di rete virtuale::

   [root@cerco ~]# dmesg | grep eth0
   e1000 0000:02:00.0: eth0: (PCI:66MHz:32-bit) 00:0c:29:40:53:f3
   e1000 0000:02:00.0: eth0: Intel(R) PRO/1000 Network Connection
   e1000: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None
   eth0: no IPv6 routers present
   
   [root@cerco ~]#

Editare il file ``/etc/sysconfig/network-scripts/ifcfg-eth0``.

In particolare vanno modificati: 

- ``HWADDR``, in cui andrà inserito l’indirizzo MAC trovato nel comando precedente;
- ``IPADDR``, in cui andrà inserito l’indirizzo IP assegnato a questa nuova VM

Se si sta installando questa VM in una nuova rete andranno ovviamente anche modificati il netmask e il gateway.

Analogamente, se ci si è spostati su una nuova rete si dovranno modificare i nameserver in ``/etc/resolv.conf``.

Modificare l'``HOSTNAME`` nel file ``/etc/sysconfig/network``::

  NETWORKING=yes
  HOSTNAME=cerco-fi

Riavviare il sistema per ricreare la configurazione dei device di rete ::

   reboot
   
Applicazioni da riconfigurare
-----------------------------

Configurare il ``ServerName`` in ``/httpd/conf/httpd.conf``.

L’indirizzo IP assegnato a questa VM non è legato a nessun nome, per cui si imposta il servername all’indirizzo IP corrente ::

   ServerName 84.33.2.27:80

Per la riconfigurazione di GeoNetwork su una macchina clonata fare riferimento 
alla documentazione :ref:`cerco_deploy_gn`.


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
| 1.3      | 2013-07-22 | ETj    | Split documenti VM/GeoNetwork                          |
+----------+------------+--------+--------------------------------------------------------+
| 1.4      | 2013-08-02 | ETj    | Porting su restructuredtext                            |
+----------+------------+--------+--------------------------------------------------------+
