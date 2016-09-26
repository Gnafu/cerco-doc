.. _reconfig_ckan:
   
=================================
Reconfiguring CKAN in a cloned VM
=================================

If you are configuring a cloned VM, there is no need to review the whole stuff: only a few data should be reconf. 
 
Usually, in a cloned machine, you only need to reconfigure the references to the IP address. Anyway you may set up 
more stuff as you see fit.


Mandatory reconfig
------------------

There are a few configurations that may prevent the application to work at all.


As reported in ":ref:`install_ckan_solr_conf`", make sure the hostname is resolved somehow.

Also, reconfig the ``ckan.site_url`` property defined in ":ref:`install_ckan_ckan_conf`".


Other reconfig
--------------

If the machine has already run, you may want to clear the CKAN DB, or if security is a concern, you may want to redefine the 
users and/or their related password. Here a list of what you may want to reset (only related to the CKAN installation):

* Password for PostgreSQL user ``ckan``
* Password for PostgreSQL user ``datastore``
* Password for PostgreSQL user ``datastorero``
* Password for CKAN sysadmin ``ckan``
* Clear and reinit db ``ckan`` 
* Clear and reinit db ``datastore`` 
* Clear and reinit Solr index
* Clear redis data
 

System account ``ckan`` was created as a *nologin* account so you don't need to reset any password for it.

