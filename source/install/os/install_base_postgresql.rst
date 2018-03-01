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

   yum install https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-7-x86_64/pgdg-centos96-9.6-3.noarch.rpm
 
EPEL repository will provide GDAL packages::

   yum install https://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm

Install PostgreSQL, PostGIS and related libs::

   yum install postgresql96 postgresql96-contrib postgresql96-server postgresql96-devel postgis2_96
       

Verify::

   rpm -qa | grep postg
  
   postgresql96-libs-....rhel7.x86_64
   postgresql96-devel-...rhel7.x86_64
   postgresql96-.........rhel7.x86_64
   postgresql96-contrib-.rhel7.x86_64
   postgis2_96-..........rhel7.x86_64
   postgresql-libs-............x86_64
   postgresql96-server-9.6.....x86_64

  
Init the DB::

   /usr/pgsql-9.6/bin/postgresql96-setup initdb
   
Enable start on boot::

   systemctl enable postgresql-9.6.service
   
Start postgres service by hand::

   systemctl start postgresql-9.6.service
      
To restart or reload the instance, you can use the following commands::

   systemctl restart postgresql-9.6.service
   systemctl reload postgresql-9.6.service
  

Setting PostgreSQL access
-------------------------

Edit the file ``/var/lib/pgsql/9.6/data/pg_hba.conf`` so that the local connection entries 
will change to::

  # "local" is for Unix domain socket connections only  
  local   all             postgres                                peer
  local   all             all                                     md5
  
  # IPv4 local connections:
  host    all             all             127.0.0.1/32            md5
  
  # IPv6 local connections:
  host    all             all             ::1/128                 md5
  



Once the configuration file has been edited, restart postgres::

   systemctl restart postgresql-9.6.service
