.. _os_tomcat_install:

###################
Tomcat Installation
###################

.. _os_java_install:

Installing Java
===============

We'll need a JDK to run GeoNetwork and Solr.

You may already have the OpenJDK package (``java-1.8.0-openjdk-devel.x86_64``) installed.
Check and see if Java is already installed:: 

   # java -version
   openjdk version "1.8.0_91"
   OpenJDK Runtime Environment (build 1.8.0_91-b14)
   OpenJDK 64-Bit Server VM (build 25.91-b14, mixed mode)
   
   # javac -version
   javac 1.8.0_91       

If it is not, check for available versions::

   yum list *openjdk*
   
You'll get a list like this one, probably with versions 1.6.0, 1.7.0, 1.8.0::
   
   [...]
   java-1.6.0-openjdk.x86_64                                                                                                   1:1.6.0.0-3.1.13.1.el6_5                                                                                           @rhel-x86_64-server-6
   java-1.6.0-openjdk-devel.x86_64                                                                                             1:1.6.0.0-3.1.13.1.el6_5                                                                                           @rhel-x86_64-server-6
   [...]
   java-1.7.0-openjdk.x86_64                                                                                                   1:1.7.0.51-2.4.4.1.el6_5                                                                                           @rhel-x86_64-server-6
   java-1.7.0-openjdk-devel.x86_64                                                                                             1:1.7.0.51-2.4.4.1.el6_5                                                                                           @rhel-x86_64-server-6
   [...]
   java-1.8.0-openjdk.x86_64                                                                                                   1:1.7.0.51-2.4.4.1.el6_5                                                                                           @rhel-x86_64-server-6
   java-1.8.0-openjdk-devel.x86_64                                                                                             1:1.7.0.51-2.4.4.1.el6_5                                                                                           @rhel-x86_64-server-6
   
Go for the version 1.8.0::

   yum install java-1.8.0-openjdk-devel
   
Once done, the command ``java -version`` should return info about the installed version. 


Oracle JDK
----------

Until recently, the Oracle JDK was a better performer than the OpenJDK,
so it was the preferred choice. This is no longer true, anyway you may find info about installing it in :ref:`install_oracle_java`. 


Installing Tomcat
=================

.. _create_user_tomcat:

Create tomcat user
------------------
:: 

  adduser -m -s /bin/bash tomcat
  passwd tomcat


.. _deploy_tomcat:

Install Tomcat files
--------------------

Let's download and install `Tomcat` first::

    mkdir -p /root/download
    cd /root/download
    wget http://it.apache.contactlab.it/tomcat/tomcat-7/v7.0.69/bin/apache-tomcat-7.0.69.tar.gz
    tar xzvf apache-tomcat-7.0.69.tar.gz -C /opt/    
    ln -s /opt/apache-tomcat-7.0.69 /opt/tomcat


.. _create_tomcat_template:

Create base template
-------------------- 

Prepare a clean instance called ``base`` to be used as a template 
for all tomcat instances::

    mkdir -p /var/lib/tomcat/base/{bin,conf,logs,temp,webapps,work}
    cp -r /opt/tomcat/conf/* /var/lib/tomcat/base/conf

And fix the permissions on the files::

    chown -R tomcat:tomcat /opt/apache*
    chown -R tomcat:tomcat /var/lib/tomcat


Instance manager script
-----------------------

To manage our Tomcat instances create the file ``/etc/systemd/system/tomcat\@.service``
with the following content::

    [Unit]
    Description=Tomcat %I
    After=network.target

    [Service]
    Type=forking
    User=tomcat
    Group=tomcat

    Environment=CATALINA_PID=/var/run/tomcat/%i.pid
    #Environment=TOMCAT_JAVA_HOME=/usr/java/default
    Environment=CATALINA_HOME=/opt/tomcat
    Environment=CATALINA_BASE=/var/lib/tomcat/%i
    Environment=CATALINA_OPTS=

    ExecStart=/opt/tomcat/bin/startup.sh
    ExecStop=/opt/tomcat/bin/shutdown.sh -force

    [Install]
    WantedBy=multi-user.target

Then make it executable::

   chmod +x /etc/systemd/system/tomcat\@.service

and grant the user `tomcat` write access to the pid file::

   mkdir /var/run/tomcat
   chown tomcat: /var/run/tomcat
   
   