.. _ckanuserbasic:

Basic concepts
##############

Datasets and resources
----------------------

CKAN organizes data using the concepts of *datasets* and *resources*.

Dataset:
  A dataset is the primary object - a "*set of data*". Datasets contain resources.

Resource:
  A resource represents individual data items in a dataset. 
  For example: a csv file, the URL of an OGC service, etc.


Both datasets and resources can have information (metadata) associated with them.

Although datasets may contain any number of resources, they will generally consist of a relatively small number of resources that are grouped together because the resource content is similar in some way. For example, a dataset may contain multiple resources that represent the same underlying data in different formats (for example: csv and xls files).


Navigating through pages
------------------------

There are 4 main kinds of pages you can navigate when in CKAN:

.. toctree::
    :maxdepth: 1
    
    nav-main.rst
    nav-datasetlist.rst
    nav-datasetview.rst
    nav-resourceview.rst
    

Authorization
-------------

CKAN can handle rights for accessing dataset and for modifying data, fine tuning them to a per-user and per-dataset authorizations.

In our use case anyway all dataset are public, so default authorizations (visitor can read anything, 
administrators can modify any information) will work well enough.       
 
  
   




