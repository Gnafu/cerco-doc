.. _install_solr:

###############
Installing Solr
###############

============
Introduction
============

Solr is a java webapp used by CKAN as a backend for dataset indexing.  
Solr shall be installed in a tomcat instance on its own, in order to decouple it from other installed webapps (i.e. GeoNetwork, Tolomeo).

It is expected that the base system has already been properly installed and configured as described in :ref:`os_tomcat_install`.

In such document there are information about how to install some required base components, such as the JDK and Apache Tomcat.


===============
Installing Solr
===============

We're going to install Solr Catalina base in ``/var/lib/tomcat/solr``; we'll put its configuration files 
in ``/etc/solr``.

Install
-------

Download solr (it's a 127MB *.tgz* file) and untar it::

   cd /root/download
   wget http://archive.apache.org/dist/lucene/solr/4.5.0/solr-4.5.0.tgz
   tar xzvf  solr-4.5.0.tgz
   
Make sure you already:

- created the tomcat user (:ref:`create_user_tomcat`)
- installed tomcat (:ref:`deploy_tomcat`)
- created the base catalina template (:ref:`create_tomcat_template`)


Create catalina base directory for solr::

   cp -a /var/lib/tomcat/base/  /var/lib/tomcat/solr

Copy .war file ::

   cp -av /root/download/solr-4.5.0/dist/solr-4.5.0.war /var/lib/tomcat/solr/webapps/solr.war
   
Copy configuration files ::

   mkdir -p /etc/solr/ckan
   cp -r /root/download/solr-4.5.0/example/solr/collection1/conf /etc/solr/ckan
   
Create file ``/etc/solr/solr.xml`` ::

   <solr persistent="true" sharedLib="lib">
      <cores adminPath="/admin/cores" defaultCoreName="ckan">
         <core name ="ckan-schema-2.0" instanceDir="ckan"> 
            <!-- <property name="dataDir" value="/var/lib/solr/data/ckan" /> -->
         </core>
      </cores>
   </solr>
   
Copy libs ::
   
   mkdir -p /opt/solr/libs
   cp solr-4.5.0/dist/*.jar                        /opt/solr/libs
   cp solr-4.5.0/contrib/analysis-extras/lib/*     /opt/solr/libs
   cp solr-4.5.0/contrib/clustering/lib/*          /opt/solr/libs
   cp solr-4.5.0/contrib/dataimporthandler/lib/*   /opt/solr/libs
   cp solr-4.5.0/contrib/extraction/lib/*          /opt/solr/libs
   cp solr-4.5.0/contrib/langid/lib/*              /opt/solr/libs
   cp solr-4.5.0/contrib/uima/lib/*                /opt/solr/libs
   cp solr-4.5.0/contrib/velocity/lib/*            /opt/solr/libs  

Backup solr config files ::

   cp /etc/solr/ckan/conf/solrconfig.xml /etc/solr/ckan/conf/solrconfig.xml.orig
   
Edit config file, commenting out all the  ``<lib dir= .....`` entries, and add::

   <lib dir="/opt/solr/libs/" regex=".*\.jar" />


Create data dir::
   
   mkdir /var/lib/tomcat/solr/data
   

Edit file ``/var/lib/tomcat/solr/bin/setenv.sh``. 
We'll set here some system vars used by tomcat, by the JVM, and by the webapp itself

::

    export CATALINA_BASE=/var/lib/tomcat/solr
    export CATALINA_HOME=/opt/tomcat/
    #export CATALINA_PID=$CATALINA_BASE/work/pidfile.pid

    export JAVA_OPTS="$JAVA_OPTS -Xms512m -Xmx800m -XX:MaxPermSize=256m"

    export JAVA_OPTS="$JAVA_OPTS -Dsolr.solr.home=/etc/solr/"
    export JAVA_OPTS="$JAVA_OPTS -Dsolr.data.dir=$CATALINA_BASE/data"

Make ``setenv.sh`` executable::

    chmod +x /var/lib/tomcat/solr/bin/setenv.sh
   
Edit server.xml
---------------

Solr is an ancillary application, so we may want to keep the default ``8080`` port for the main application, 
such as GeoNetwork.
We will change the tomcat ports in file `/var/lib/tomcat/solr/conf/server.xml` in this way:

- 8004 for commands to catalina instance
- 8081 for the HTTP connection

We won't need the AJP connection, since Solr will be not exposed to the internet via apache httpd, so comment out the 
AJP connector.

See also :ref:`application_ports`.


Webapp directory ownership
--------------------------

Set the ownership of the ``solr/`` related directories to user tomcat ::

   chown tomcat: -R /var/lib/tomcat/solr
   chown tomcat: -R /etc/solr/
   
In order to make solr work with CKAN, a schema needs to be set.
It will be set in a following section, so we do not want to start solr right away.  

.. _setup_solr_startup:

==========================
Starting and stopping Solr
==========================

Autostart
---------

The standard Systemd way for setting Solr as an autostarting service is::

   systemctl enable tomcat@solr
   

Commands
--------

Once Solr has been installed, you can start it with::

   systemctl start  tomcat@solr

These are the commands for starting, stopping and querying Solr:

- ``systemctl start  tomcat@solr``
- ``systemctl stop   tomcat@solr``
- ``systemctl status tomcat@solr``
