.. _os_postgres_install:

=================================
Installing PostgreSQL and PostGIS
=================================

Install PostgreSQL
------------------

CentOS repositories provide the PostgreSQL package, but not the PostGIS extensions.
We need to add the PGDG repo for PostGIS (it will also provide access to more recente PostgreSQL versions, if needed),
and the EPEL repo for some PostGIS deps. 

Update the packages list::

   yum check-update
   
Install the package for configuring the PGDG repository::

   yum install http://yum.postgresql.org/9.4/redhat/rhel-7-x86_64/pgdg-centos94-9.4-2.noarch.rpm
 
EPEL repository will provide GDAL packages::

   yum install http://mirror.sfo12.us.leaseweb.net/epel/7/x86_64/e/epel-release-7-6.noarch.rpm 

Install PostgreSQL, PostGIS and related libs::

   yum install postgresql94 postgresql94-contrib postgresql94-server postgresql94-devel postgis2_94
       

Verify::

   rpm -qa | grep postg
  
   postgresql94-libs-9.4.8-1PGDG.rhel7.x86_64
   postgresql94-devel-9.4.8-1PGDG.rhel7.x86_64
   postgresql94-9.4.8-1PGDG.rhel7.x86_64
   postgresql94-contrib-9.4.8-1PGDG.rhel7.x86_64
   postgis2_94-2.1.8-1.rhel7.x86_64
   postgresql-libs-9.2.15-1.el7_2.x86_64
   postgresql94-server-9.4.8-1PGDG.rhel7.x86_64

  
Init the DB::

   /usr/pgsql-9.4/bin/postgresql94-setup initdb
   
Enable start on boot::

   systemctl enable postgresql-9.4.service
   
Start postgres service by hand::

   systemctl start postgresql-9.4.service
      
To restart or reload the instance, you can use the following commands::

   systemctl restart postgresql-9.4.service
   systemctl reload postgresql-9.4.service
  

Setting PostgreSQL access
-------------------------

Edit the file ``/var/lib/pgsql/9.4/data/pg_hba.conf`` so that the local connection entries 
will change to::

  # "local" is for Unix domain socket connections only  
  local   all             postgres                                peer
  local   all             all                                     md5
  
  # IPv4 local connections:
  host    all             all             127.0.0.1/32            md5
  
  # IPv6 local connections:
  host    all             all             ::1/128                 md5
  



Once the configuration file has been edited, restart postgres::

   systemctl restart postgresql-9.4.service

   
