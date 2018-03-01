.. _ckan_datastore_setup:

================
DataStore plugin
================

The CKAN DataStore extension provides an *ad hoc* database for storage of structured data from CKAN resources. 

.. hint::
   Ref info page at http://docs.ckan.org/en/ckan-2.5.2/maintaining/datastore.html


Database
--------

Create database user and a DB for the datastore:: 

   su - postgres -c "createuser -S -D -R -P -l datastore"
   su - postgres -c "createdb -O ckan datastore -E utf-8"

Make sure you also created the ``ckan`` DB user as documented in :ref:`ckan_db_setup`.  


Configuration file
------------------

Open the file ``/etc/ckan/default/production.ini`` and add the ``datastore`` plugin::

   ckan.plugins = datastore [... other plugins...] 


Also set up the access to the datastore DB:: 

   ckan.datastore.write_url = postgresql://ckan:PASSWORD@localhost/datastore
   ckan.datastore.read_url = postgresql://datastore:PASSWORD@localhost/datastore


Database grants
---------------

CKAN needs to change some grants on the datastore.

CKAN can create the SQL script file, that shall be then run with ``postgres`` privileges.

Create the file as the ``ckan`` user:: 

   cd
   . default/bin/activate
   paster --plugin=ckan datastore set-permissions -c /etc/ckan/default/production.ini > set_permissions.sql

Then execute the ``.sql`` file as postgres; or, as ``root``, run::

   su - postgres -c "psql  postgres -f /usr/lib/ckan/set_permissions.sql"

Restart CKAN to enable the datastore plugin:: 
 
   systemctl restart supervisord
   
Then perform a ruequest to your server to make sure the datastore plugin replies properly:: 
   
   http://YOUR_SITE/api/3/action/datastore_search?resource_id=_table_metadata


.. _ckan_filestore_setup:
      
===================
File storage plugin
===================

FileStore allows users to upload data files to CKAN resources, 
and to upload logo images for groups and organizations.
 
.. hint::
   Ref info page at http://docs.ckan.org/en/ckan-2.5.2/maintaining/filestore.html

*FileStore* is used to enable data upload in CKAN. 

Create directory ::

   mkdir -p /var/lib/ckan/upload
   chown ckan: -R /var/lib/ckan


Set the storage config in ``production.ini``::

   ckan.storage_path = /var/lib/ckan/upload


.. _ckan_datapusher_setup:

==========
DataPusher
==========

Automatically add Data to the CKAN DataStore.

.. hint::
   Doc page at http://docs.ckan.org/projects/datapusher/en/latest/index.html

As ``root`` install the WSGI apache module:: 

   yum install mod_wsgi

As ``ckan``, create a brand new virtualenv, and install the datapusher app in it:: 

   virtualenv /usr/lib/ckan/datapusher
   mkdir /usr/lib/ckan/datapusher/src
   cd /usr/lib/ckan/datapusher/src
   git clone -b stable https://github.com/ckan/datapusher.git
   cd datapusher/
   . ../../bin/activate
   pip install setuptools==36.1 
   pip install -r requirements.txt
   python setup.py develop

Create configuration files::

    cp /usr/lib/ckan/datapusher/src/datapusher/deployment/datapusher_settings.py /etc/ckan/default/datapusher_settings.py
     
    cp /usr/lib/ckan/datapusher/src/datapusher/deployment/datapusher.wsgi /etc/ckan/default/datapusher.wsgi
    
Then edit ``/etc/ckan/default/datapusher.wsgi`` and adjust the settings path from::  

    os.environ['JOB_CONFIG'] = '/etc/ckan/datapusher_settings.py'
    
to ::

    os.environ['JOB_CONFIG'] = '/etc/ckan/default/datapusher_settings.py'

Then create a file name ``/etc/httpd/conf.d/94-datapusher.conf`` and add these lines::

    Listen 8800
   
    <VirtualHost 0.0.0.0:8800>
   
       ServerName ckan
   
       # this is our app
       WSGIScriptAlias / /etc/ckan/default/datapusher.wsgi
   
       # pass authorization info on (needed for rest api)
       WSGIPassAuthorization On
   
       # Deploy as a daemon (avoids conflicts between CKAN instances)
       WSGIDaemonProcess datapusher display-name=demo processes=1 threads=15
   
       WSGIProcessGroup datapusher
   
       ErrorLog /var/log/httpd/datapusher.error.log
       CustomLog /var/log/httpd/datapusher.log combined
   
       <Directory "/" >
          Require all granted
       </Directory>
   
    </VirtualHost>

Now let's allow connections to port 8800 in SELinux::  

   semanage port -a -t http_port_t -p tcp 8800
    
and restart httpd in order to load the new configuration::

   systemctl restart httpd

Test the datapusher entrypoint with a request like ::

    curl http://localhost:8800
    
on the same machine ckan is running on.  
You should get a response like this::

   {
     "help": "\n        Get help at:\n        http://ckan-service-provider.readthedocs.org/."
   }

   
Now let's make ckan aware that the datapusher is available.

Edit the file ``/etc/ckan/default/production.ini`` and: 

- add the ``datapusher`` plugin::

     ckan.plugins = [... other plugins...] datapusher
 
- remove the comments from the lines::

     ckan.datapusher.formats = csv xls xlsx tsv application/csv application/vnd.ms-excel application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
     ckan.datapusher.url = http://127.0.0.1:8800/
     
Eventually restart supervisord to make ckan reload the configuration::

     systemctl restart supervisord
