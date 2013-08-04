.. _cerco_deploy_tolomeo:

######################################
Installazione e configurazione Tolomeo
######################################

Version 1.0
22/07/2013

============
Introduzione
============

Si presuppone che il sistema base sia già stato installato e configurato come descritto nel documento :ref:`cerco_deploy_gn`.
Su tale documento sono infatti descritte le procedure per l’installazione di alcuni componenti necessarie, 
ad esempio Apache HTTPD, Oracle Java, ApacheTomcat.

In questo documento sono esplicitate solo le informazioni per l’installazione di Tolomeo.

=====================
Installazione Tolomeo
=====================

Si suppone sia stata creata la directory ``/var/lib/tomcat/base/`` come indicato nel paragrafo 
:ref:`cerco_deploy_tomcat` nel documento :ref:`cerco_setup_vm`.

Installazione e configurazione webapp
-------------------------------------

Scaricare la versione desiderata di tolomeo, che consiste nei due file ``tolomeo.war`` e ``mycommon.war``.

Creare la directory base per tolomeo::

   cp -a /var/lib/tomcat/base/  /var/lib/tomcat/tolomeo

Copiare i file .war in ``/var/lib/tomcat/tolomeo/webapps/``.

Modifica server.xml
-------------------

La configurazione di default prevede l’uso delle porte

- 8005 per lo shutdown
- 8080 per la connessione HTTP
- 8009 per AJP

Come da tabella in :ref:`cerco_apache_port` useremo le seguenti porte:

- shutdown: 8007
- HTTP: 8082
- AJP: 8011

===============================
Configurazione avvio automatico
===============================

Creare il file ``/etc/init.d/geonetwork caricandolo`` da http://demo.geo-solutions.it/share/cerco/tolomeo/tolomeo

Una volta creato il file, impostarlo come file eseguibile ::

   chmod +x /etc/init.d/tolomeo

e configurare l’avvio automatico con ::

    chkconfig --add tolomeo

.. _tolomeo_config_httpd:

===========================
Configurazione apache httpd
===========================

Per poter raggiungere tolomeo sulla porta 80 attraverso httpd, è necessario configurare un reverse proxing.

Da utente root creare il file
   ``/etc/httpd/conf.d/91tolomeo.conf``

e inserire le righe::

   ProxyPass        /tolomeo ajp://localhost:8011/tolomeo
   ProxyPassReverse /tolomeo ajp://localhost:8011/tolomeo

   ProxyPass        /mycommon ajp://localhost:8011/mycommon
   ProxyPassReverse /mycommon ajp://localhost:8011/mycommon

e quindi caricare la nuova configurazione con ::

   service httpd reload

Ora Tolomeo dovrebbe essere raggiungibile all’indirizzo: http://SERVER_IP/tolomeo

=========================
Installazione alternativa
=========================

Nel caso in cui si volesse installare tolomeo nella stessa istanza tomcat di geonetwork, servirà solamente:

- copiare i file ``tolomeo.war`` e ``mycommon.war`` in ``/var/lib/tomcat/geonetwork/webapps/``.
- creare il file ``/etc/httpd/conf.d/91tolomeo.conf`` come da paragrafo :ref:`tolomeo_config_httpd`, 
  usando però le porte del tomcat GeoNetwork (8009, se si è seguita la documentazione in :ref:`cerco_apache_port`) e non 8011.
- ricaricare la configurazione di httpd con il comando 
     ``service httpd reload``


In questo caso tolomeo verrà fermato e riavviato insieme a GeoNetwork con i comandi ::

   service geonetwork start

e ::

   service geonetwork stop

===============================
Configurazione CKAN per Tolomeo
===============================
  
Per la configurazione di integrazione tra CKAN e Tolomeo, far riferimento alla sezione :ref:`config_tolomeo_ckan` 
in :ref:`cerco_deploy_ckan`.


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

