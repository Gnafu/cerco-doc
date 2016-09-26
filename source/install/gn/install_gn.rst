.. _install_gn:

##########################
Installing GeoNetwork 2.10
##########################

============
Introduction
============

In this document you'll only find specific information for installing GeoNetwork.

It is expected that the base system has already been properly installed and configured as described in :ref:`os_installation_index`.

In such document there are information about how to install some required base components, such as PostgreSQL, 
Apache HTTPD, Oracle Java, Apache Tomcat.

=====================
Installing GeoNetwork
=====================

.. hint::
   GeoNetwork project page at http://geonetwork-opensource.org/
      
We're going to install Tolomeo Catalina base in ``/var/lib/tomcat/geonetwork``.

Make sure you already:

- created the tomcat user (:ref:`create_user_tomcat`)
- installed tomcat (:ref:`deploy_tomcat`)
- created the base catalina template (:ref:`create_tomcat_template`)


Download packages
-----------------

.. note::
   Latest official version in the 2.10.x branch is 2.10.3, but it's missing lots of fixes committed after its release. 
   That's why we're pointing to a nighlty build. 

Download the `.war` files needed for a full GeoNetwork installation::

   cd /root/download
   wget http://build.geo-solutions.it/geonetwork/2.10.x/nightly/latest/geonetwork.war
   wget http://build.geo-solutions.it/geonetwork/2.10.x/RNDT/iso19139.rndt.zip



Setup tomcat base
-----------------

Create catalina base directory for GeoNetwork::

   cp -a /var/lib/tomcat/base/       /var/lib/tomcat/geonetwork
   cp /root/download/geonetwork.war  /var/lib/tomcat/geonetwork/webapps/


.. _gn_create_db:

Create user and DB for GeoNetwork
---------------------------------

Create a PostgreSQL DB for GeoNetwork::

   su - postgres -c "createuser -S -D -R -P -l geonetwork"

Annotate the user password.   
   
Create the DB::
   
   su - postgres -c "createdb -O geonetwork geonetwork -E utf-8"

Add the spatial extension to the ``geonetwork`` DB::

   # su - postgres -c "psql geonetwork"
   geonetwork=# CREATE EXTENSION postgis;
   geonetwork=# GRANT ALL PRIVILEGES ON DATABASE geonetwork TO geonetwork;
   geonetwork=# GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO geonetwork;

.. _gn_create_datadir:

Create GN data dir
------------------

Some GN dirs can be externalized.

We'll put such dirs in ``/var/lib/tomcat/geonetwork/gn``, in this structure::

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


Create the directory hierarchy::

   cd /var/lib/tomcat/geonetwork/
   mkdir -p gn/data/{metadata_subversion,metadata_data}
   mkdir -p gn/data/resources/images/logos/
   mkdir -p gn/data/upload
   mkdir -p gn/index/nonspatial/

Create the override file:: 

   vim /var/lib/tomcat/geonetwork/gn/config-overrides.xml

and insert :download:`this content <resources/gn-config-overrides.xml>`.

You will have to customize at least:

* the ``site.host`` element, setting the IP address or the server host name;
* the password for the geonetwork DB

You may also want to customize:

* the site name
* the bounding box and the layers for the search map.
  Please note that there are 2 sets of map definition:

  * ``<mapSearch>`` is about the search map 
  * ``<mapViewer>`` is about the preview map

setenv.sh
---------

Create the file ``setenv.sh``. 
We'll set here some system vars used by tomcat, by the JVM, and by the webapp itself::

   vim /var/lib/tomcat/geonetwork/bin/setenv.sh

Insert this content::

   # Do not set tomcat vars: they are already set in systemd setup
   #export CATALINA_BASE=/var/lib/tomcat/geonetwork
   #export CATALINA_HOME=/opt/tomcat/  
   #export CATALINA_PID=$CATALINA_BASE/work/pidfile.pid
  
   # Configure memory and system stuff   
   export JAVA_OPTS="$JAVA_OPTS -Xms1024m -Xmx2048m -XX:MaxPermSize=512m"
   export JAVA_OPTS="$JAVA_OPTS -Dorg.apache.lucene.commitLockTimeout=60000"

   # Configure GeoNetwork  
   export GN_EXT_DIR=$CATALINA_BASE/gn

   # Configure override file  
   export GN_OVR_PROPNAME=geonetwork.jeeves.configuration.overrides.file
   export GN_OVR_FILE=$GN_EXT_DIR/config-overrides.xml 
   export JAVA_OPTS="$JAVA_OPTS -D$GN_OVR_PROPNAME=$GN_OVR_FILE"
  
   #export JAVA_OPTS="$JAVA_OPTS -Dgeonetwork.dir=$GN_DATA_DIR"
  
   # Configure data dirs
   export GN_CTX=geonetwork.  
   export JAVA_OPTS="$JAVA_OPTS -D${GN_CTX}data.dir=$GN_EXT_DIR/data/metadata_data"
   export JAVA_OPTS="$JAVA_OPTS -D${GN_CTX}resources.dir=$GN_EXT_DIR/data/resources"
   export JAVA_OPTS="$JAVA_OPTS -D${GN_CTX}svn.dir=$GN_EXT_DIR/data/metadata_subversion"
   export JAVA_OPTS="$JAVA_OPTS -D${GN_CTX}lucene.dir=$GN_EXT_DIR/index"
   
and make it executable::

   chmod +x /var/lib/tomcat/geonetwork/bin/setenv.sh


Edit server.xml
---------------

We need to assign 3 ports to this catalina instance.
We want to keep the default ports for this tomcat instance (see :ref:`application_ports`)

Open file ::

   vim /var/lib/tomcat/geonetwork/conf/server.xml

and make sure the connection ports are set in this way: 

- 8005 for commands to catalina instance
- 8080 for the HTTP connections
- 8009 for the AJP connections


Tomcat dir ownership
--------------------

Set the ownership of the ``geonetwork/`` related directories to user tomcat ::

   chown tomcat: -R /var/lib/tomcat/geonetwork
 
 
.. _setup_geonetowrk_startup:

================================
Starting and stopping GeoNetwork
================================

.. note::
   Before running GeoNetwork the first time, you may want to set the log file location. 
   See  :ref:`gn_log_config`.


Autostart
---------

The standard Systemd way for setting GeoNetwork as an autostarting service is::

   systemctl enable tomcat@geonetwork
   

Commands
--------

Once GeoNetwork has been installed, you can start it with::

   systemctl start  tomcat@geonetwork

These are the commands for starting, stopping and querying GeoNetwork:

- ``systemctl start  tomcat@geonetwork``
- ``systemctl stop   tomcat@geonetwork``
- ``systemctl status tomcat@geonetwork``
      
   
===============
Configure httpd
===============
   
Create the file ``/etc/httpd/conf.d/80-geonetwork.conf`` and insert these lines::

   ProxyPass        /geonetwork   ajp://localhost:8009/geonetwork                                                                                                                                                                                                                           
   ProxyPassReverse /geonetwork   ajp://localhost:8009/geonetwork


Then reload the configuration for apache httpd::

   service httpd reload


============
Known issues
============

* site name and site URL set in the override file are not put in the DB during the initialization, 
  so a manual setup in the configuration page is required. 

==============
Other settings
==============

There are some settings that are not straightforward, and that require manual editing of configurations files. 
 

.. _gn_log_config:

Log file location
-----------------

GeoNetwork log settings are set to create the log files into ``CURRENT_DIRECTORY/logs/geonetwork.log``.
It means that, running GeoNetwork with the configuration explained in this document, you'll get the log files into
``/home/tomcat/logs/geonetwork.log``.  

If you wish to customize the log location, you'll have to edit the file ``WEB-INF/log4j.cfg``. 

You may want to change the path in the log4j configuration file before running the GeoNetwork service the first time, in order 
not to have temp log files placed in unwanted places. 

- Expand the war file (if GN has not been started yet) ::

   cd /var/lib/tomcat/geonetwork/webapps/
   mkdir geonetwork
   cd geonetwork
   jar xvf ../geonetwork.war

- Edit the file ``WEB-INF/log4j.cfg``, setting the property ``log4j.appender.jeeves.file`` as follows::

   log4j.appender.jeeves.file = ${catalina.base}/logs/geonetwork.log

  Make sure you have the ``${catalina.base}`` part. In this way, the logfile should be created in the directory   
  ``/var/lib/tomcat/geonetwork/logs/``.

- Change ownership for all the expanded files to user ``tomcat``::

   chown tomcat: -R /var/lib/tomcat/geonetwork


Default language
----------------

The only way to change de default UI language is to edit the index.html file::

   vim webapps/geonetwork/index.html
   
The default language is set as a 3 letters ISO code in this line::
   
   window.location="srv/eng/home" + search;
   
so you may for instance change the string to ``srv/ita/home`` to have Italian as default language. 


