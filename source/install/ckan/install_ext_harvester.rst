.. _ckan_harvester_setup:

================
Harvester plugin
================

As root install::

   yum install redis
   
and start redis::
   
   systemctl enable redis
   systemctl start redis
         

Installing the CKAN harvester
-----------------------------

As user ``ckan``::

   . default/bin/activate
   cd default/src
   git clone https://github.com/ckan/ckanext-harvest.git
   cd ckanext-harvest/   
   pip install -e .
   pip install -r pip-requirements.txt
   
Edit file ``/etc/ckan/default/production.ini`` and add the harvester related plugins::  

   ckan.plugins = [...] harvest ckan_harvester
   ckan.harvest.mq.type = redis

Init the db for the harvester services::

   paster --plugin=ckanext-harvest harvester initdb --config=/etc/ckan/default/production.ini


.. _install_ckan_harvesting_script:

Script harvesting
-----------------

Running harvesting procedure requires issuing a couple of command lines.
It's handy to create a script file that runs them. We'll use the same script to run the cron'ed harvest.

Create the file ``/usr/lib/ckan/run_harvester.sh`` and add the following lines::

   #!/bin/bash

   . /usr/lib/ckan/default/bin/activate

   paster --plugin=ckanext-harvest harvester job-all --config=/etc/ckan/default/production.ini
   paster --plugin=ckanext-harvest harvester run     --config=/etc/ckan/default/production.ini

and make it executable::

   chmod +x /usr/lib/ckan/run_harvester.sh
   
.. important::
   The "official" script would only require the line with ``harvester run``.
   The line  containing the ``harvester job-all`` is an additional command that will force harvesting from
   all the configured sources.

   See :ref:`ckan_harvesting_running` for further details.  

Periodic harvesting
-------------------

Add a cron job for the harvester::

   crontab -e -u ckan

Add in the crontab the following line to run the harvesting every 15 minutes::

   */15 * * * * /usr/lib/ckan/run_harvester.sh

=========================
supervisord configuration
=========================

CKAN does not provide a default script for autostarting; we'll use the *supervisord* daemon to do that.

You should already have installed it when installing CKAN at :ref:`install_supervisord_ckan`


As root create the file ``/etc/supervisord.d/gather.ini`` and put in it these lines::

   [program:ckan_gather_consumer]
   command=/usr/lib/ckan/default/bin/paster --plugin=ckanext-harvest harvester gather_consumer --config=/etc/ckan/default/production.ini
   user=ckan
   autostart=true
   autorestart=true
   numprocs=1
   log_stdout=true
   log_stderr=true
   stdout_logfile=/var/log/ckan/gather_out.log
   stderr_logfile=/var/log/ckan/gather_err.log
   logfile=/var/log/ckan/gather.log
   startsecs=10
   startretries=3


Create file ``/etc/supervisord.d/fetch.ini`` and put in this content:: 

   [program:ckan_fetch_consumer]
   command=/usr/lib/ckan/default/bin/paster --plugin=ckanext-harvest harvester fetch_consumer --config=/etc/ckan/default/production.ini
   user=ckan
   autostart=true
   autorestart=true
   numprocs=1
   log_stdout=true
   log_stderr=true
   stdout_logfile=/var/log/ckan/fetch_out.log
   stderr_logfile=/var/log/ckan/fetch_err.log
   logfile=/var/log/ckan/fetch.log
   startsecs=10
   startretries=3

Then restart supervisord::

   systemctl restart supervisord

