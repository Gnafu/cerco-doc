.. _gn_web_config:

=============
Further setup
=============

Once GeoNetwork is up and running, you have to perform some other steps using the web interface.

Login as ``admin`` / ``admin``.


Change the admin pw
-------------------

Go to "Administration" >  "Users and groups" >  "Change password".
Change and annotate the new password.


Check the system configuration
------------------------------

Go to "Administration" >  "Catalogue settings" >  "System configuration".

Check if the right values are set in these fields:

* Site name
* Site organization
* Host
* Port (you may want to put ``80`` here) 

You then may want to:

* Disable Z39.50 server
* Enable search statistics
* Enable INSPIRE
* Enable INSPIRE view
* Setup the CSW server info


Load the INSPIRE thesauri
-------------------------

Go to "Administration" >  "Manage thesauri".
 
- Press "Add" 
- Choose "From remote file (URL)"
- Select the radio option "from thesaurus repository",
- Select the entry "INSPIRE Themes (in all EU languages)"

Repeat, adding the "INSPIRE service taxonomy" as well.


Logo
----

You may customize the site logo in the administration page. 

In the option group "Catalogue settings" select "Logo configuration".
Upload the image you wish to use as the site logo. Once loaded, select it and click on "Use for this catalog".

.. note: 
   In previous GeoNetwork releases you had to use the non-interactive procedure:
   You had to identify the site UUID (in the info page -- "Info" link on the toolbar). 
   Then you had to copy the ``gif`` file into the directory ``images/logos``, 
   with name ``SITE_UUID.gif``.

