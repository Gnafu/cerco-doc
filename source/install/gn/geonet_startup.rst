.. _setup_gn_startup:

################################
Starting and stopping GeoNetwork
################################

Autostart
=========

The standard Systemd way for setting an autostarting service is:

   systemctl enable tomcat@geonetwork
   

Commands
========

Once GeoNetwork has been installed, you can start it with::

   systemctl start  tomcat@geonetwork

These are the commands for starting and stopping GeoNetwork:

- ``systemctl start  tomcat@geonetwork``
- ``systemctl stop   tomcat@geonetwork``
- ``systemctl status tomcat@geonetwork``
