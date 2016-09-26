.. _install_tolomeo:

##################
Installing Tolomeo
##################

============
Introduction
============

`Tolomeo <http://tolomeogis.comune.prato.it/>`_ is a java map client webapp. It can be used both as a standalone map client, or can be embedded within other 
apps. 
  
Tolomeo shall be installed in a tomcat instance on its own, in order to decouple it from other installed webapps (i.e. GeoNetwork, Solr).

A new Tolomeo instance is **optional** in the OpenDataNetwork architecture, since a node may want to reuse existing Tolomeo instances. 

It is expected that the base system has already been properly installed and configured as described in :ref:`os_tomcat_install`.

In such document there are information about how to install some required base components, such as the JDK and Apache Tomcat.


========================
Installing Tolomeo 3.7.1
========================

We're going to install Tolomeo Catalina base in ``/var/lib/tomcat/tolomeo``.

Make sure you already:

- created the tomcat user (:ref:`create_user_tomcat`)
- installed tomcat (:ref:`deploy_tomcat`)
- created the base catalina template (:ref:`create_tomcat_template`)


Install
-------

Download Tolomeo (it's a 90MB *.tgz* file) and unzip it::

   cd /root/download
   wget http://tolomeogis.comune.prato.it/download/tolomeo/3.7.1/tolomeo-3.7.1-war.zip
   unzip tolomeo-3.7.1-war.zip
   

Create catalina base directory for Tolomeo::

   cp -a /var/lib/tomcat/base/  /var/lib/tomcat/tolomeo

Copy .war file ::

   cp -av /root/download/tolomeo.war /var/lib/tomcat/tolomeo/webapps
      

Configuration
-------------

Tolomeo needs a config directory to start.
You can use the sample config in the .war file. 

You can have tomcat extract the war file for you, but it needs to be run first, and as a first run it will end with an error.
Let's unpack the .war file ourselves::

   cd /var/lib/tomcat/tolomeo/webapps
   mkdir tolomeo
   cd tolomeo
   jar -xzvf ../tolomeo.war
   cd ../..   
   cp -a  webapps/tolomeo/WEB-INF/config .

Tolomeo needs to know where such file is.

Edit the file ``webapps/tolomeo/WEB-INF/web.xml`` and add the element::

   <context-param>
      <param-name>configFilePath</param-name>
      <param-value>/var/lib/tomcat/tolomeo/config/tolomeo.properties</param-value>
   </context-param>


Other configuration
-------------------

Should you need to change the memory setting for the Tolomeo tomcat instance, 
edit (create if necessary) the file ``/var/lib/tomcat/tolomeo/bin/setenv.sh`` and add the line ::


    export JAVA_OPTS="$JAVA_OPTS -Xms512m -Xmx800m -XX:MaxPermSize=256m"

Then make ``setenv.sh`` executable::

    chmod +x /var/lib/tomcat/tolomeo/bin/setenv.sh
   
Edit server.xml
---------------

We have to setup ports for Tolomeo, also according to the other tomcat instances running on the same machine. 

According to :ref:`application_ports` we will change the tomcat ports in file `/var/lib/tomcat/tolomeo/conf/server.xml` in this way:

- 8003 for commands to catalina instance
- 8082 for the HTTP connection
- 8010 for the AJP connection



Webapp directory ownership
--------------------------

Set the ownership of the ``tolomeo/`` related directories to user tomcat ::

   chown tomcat: -R /var/lib/tomcat/tolomeo


.. _setup_tolomeo_startup:

=============================
Starting and stopping Tolomeo
=============================

Autostart
---------

The standard Systemd way for setting Tolomeo as an autostarting service is::

   systemctl enable tomcat@tolomeo
   

Commands
--------

Once Tolomeo has been installed, you can start it with::

   systemctl start  tomcat@tolomeo

These are the commands for starting, stopping and querying Tolomeo status:

- ``systemctl start  tomcat@tolomeo``
- ``systemctl stop   tomcat@tolomeo``
- ``systemctl status tomcat@tolomeo``





.. _setup_tolomeo_httpd:

==========================
Apache httpd configuration
==========================

As ``root``, create the file ``/etc/httpd/conf.d/91-tolomeo.conf`` and add the following content::
 
   ProxyPass        /tolomeo   ajp://localhost:8010/tolomeo
   ProxyPassReverse /tolomeo   ajp://localhost:8010/tolomeo


and reload the configuration ::

   systemctl reload httpd

