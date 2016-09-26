.. _install_ckan_other:

#####################
Other CKAN extensions
#####################

============
Introduction
============

In this document you'll only find specific information for installing some CKAN official and 
unofficial extensions.

.. _extension_tracker:

=======
Tracker
=======

Tracks visit to the site and to single datasets.

.. hint::
   Doc page at http://docs.ckan.org/en/tracking-fixes/tracking.html
    
Edit the file ``/etc/ckan/default/production.ini`` and add the line ::

   ckan.tracking_enabled = true
   
Then create a script ``tracker_update.sh`` like this::

    #!/bin/bash

    . /usr/lib/ckan/default/bin/activate

    paster --plugin=ckan tracking update         -c /etc/ckan/default/production.ini 
    paster --plugin=ckan search-index rebuild -r -c /etc/ckan/default/production.ini

You can use this file directly to run the index rebuilding, or use it in cron to make it run periodically.

As user ``root`` use ::

     crontab -e -u ckan
     
or as user ``ckan``::

     crontab -e
     
and add the line::

   0 * * * * /usr/lib/ckan/tracker_update.sh >>/var/log/ckan/tracker.log 2>&1

       