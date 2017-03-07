.. _install_ext_dcatapit:

###################################
Installing the DCAT-AP_IT extension
###################################

============
Introduction
============

CKAN extension for the Italian Open Data Portals (DCAT_AP-IT).

====================
DCAT-AP_IT extension
====================

Overview 
--------

This extension provides plugins that allow CKAN to expose and consume metadata from other catalogs using RDF documents serialized according to the Italian DCAT Application Profile. The Data Catalog Vocabulary (DCAT) is "an RDF vocabulary designed to facilitate interoperability between data catalogs published on the Web".


Requirements
------------

The ckanext-dcatapit extension has been developed for CKAN 2.4 or later and is based on the ckanext-dcat plugin. In order to use the dcatapit CSW harvester functionalities, you need to install also the ckanext-spatial extension.


Installation 
------------            

1. Install the **ckanext-spatial** extension as described in :ref:`install_ckan_spatial` 

.. note:: Install this extension only if you need to use the dcatapit CSW harvester (see below).

2. Install the **ckanext-dcat** extension.

As user ``ckan``::

	   $ . /usr/lib/ckan/default/bin/activate
	   (default)$ cd /usr/lib/ckan/default/src
	   (default)$ git clone https://github.com/ckan/ckanext-dcat.git
	   (default)$ cd ckanext-dcat
	   (default)$ pip instal -e .
	   (default)$ pip install -r requirements.txt
	   
Enable the required plugins in your ini file:

ckan.plugins = [...] dcat dcat_rdf_harvester dcat_json_harvester dcat_json_interface

3. Install the **ckanext-dcatapit** extension.

As user ``ckan``::

	   $ . /usr/lib/ckan/default/bin/activate
	   (default)$ cd /usr/lib/ckan/default/src
	   (default)$ git clone https://github.com/geosolutions-it/ckanext-dcatapit.git
	   (default)$ cd ckanext-dcatapit
	   (default)$ pip instal -e .
	   
Enable the required plugins in your ini file::

		ckan.plugins = [...] dcatapit_pkg dcatapit_org dcatapit_config

In order to enable also the RDF harvester add ``dcatapit_harvester`` to the ``ckan.plugins`` setting in your CKAN::

		ckan.plugins = [...] dcatapit_pkg dcatapit_org dcatapit_config dcatapit_harvester

In order to enable also the CSW harvester add ``dcatapit_csw_harvester`` to the ``ckan.plugins`` setting in your CKAN::

		ckan.plugins = [...] dcatapit_pkg dcatapit_org dcatapit_config dcatapit_harvester dcatapit_csw_harvester

4. Enable the dcatapit profile adding the following configuration property in the ``production.ini`` file::

		`ckanext.dcat.rdf.profiles = euro_dcat_ap it_dcat_ap`

5. Configure the CKAN base URI::

		`ckanext.dcat.base_uri = YOUR_BASE_URI`

6. Initialize the CKAN DB with the mandatory table needed for localized vocabulary voices::

		`paster --plugin=ckanext-dcatapit vocabulary initdb --config=/etc/ckan/default/production.ini`

7. Then restart CKAN to make it load this new extensions.
     
8. The EU controlled vocabularies must be populated before start using the dcatapit plugin. Execute in sequence these commands::

		paster --plugin=ckanext-dcatapit vocabulary load --url http://publications.europa.eu/mdr/resource/authority/language/skos/languages-skos.rdf --name languages --config=/etc/ckan/default/production.ini
    
		paster --plugin=ckanext-dcatapit vocabulary load --url http://publications.europa.eu/mdr/resource/authority/data-theme/skos/data-theme-skos.rdf --name eu_themes --config=/etc/ckan/default/production.ini
    
		paster --plugin=ckanext-dcatapit vocabulary load --url http://publications.europa.eu/mdr/resource/authority/place/skos/places-skos.rdf --name places --config=/etc/ckan/default/production.ini
    
		paster --plugin=ckanext-dcatapit vocabulary load --url http://publications.europa.eu/mdr/resource/authority/frequency/skos/frequencies-skos.rdf --name frequencies --config=/etc/ckan/default/production.ini
    
		paster --plugin=ckanext-dcatapit vocabulary load --url http://publications.europa.eu/mdr/resource/authority/file-type/skos/filetypes-skos.rdf  --name filetype --config=/etc/ckan/default/production.ini
	
	
DCAT_AP-IT CSW Harvester
------------------------

The ckanext-dcatapit extension provides also a CSW harvester built on the **ckanext-spatial** extension, and inherits all of its functionalities. With this harvester you can harvest dcatapit dataset fields from the ISO metadata. The CSW harvester uses a default configuration usefull for populating mandatory fields into the source metadata, this json configuration can be customized into the harvest source form (please see the default one `into the harvester file <https://github.com/geosolutions-it/ckanext-dcatapit/blob/master/ckanext/dcatapit/harvesters/csw_harvester.py#L54>`_ ).

Below an example of the available configuration properties (for any configuration property not specified, the default one will be used)::

    {
       "dcatapit_config":{
          "dataset_themes":"OP_DATPRO",
          "dataset_places":"ITA_BZO",
          "dataset_languages":"{ITA,DEU}",
          "frequency":"UNKNOWN",
          "agents":{
             "publisher":{
                "code":"p_bz",
                "role":"publisher",
                "code_regex":{
                   "regex":"\\(([^)]+)\\:([^)]+)\\)",
                   "groups":[2]
                },
                "name_regex":{
                   "regex":"([^(]*)(\\(IPa[^)]*\\))(.+)",
                   "groups":[1, 3]
                }
             },
             "owner":{
                "code":"p_bz",
                "role":"owner",
                "code_regex":{
                   "regex":"\\(([^)]+)\\:([^)]+)\\)",
                   "groups":[2]
                },
                "name_regex":{
                   "regex":"([^(]*)(\\(IPa[^)]*\\))(.+)",
                   "groups":[1, 3]
                }
             },
             "author":{
                "code":"p_bz",
                "role":"author",
                "code_regex":{
                   "regex":"\\(([^)]+)\\:([^)]+)\\)",
                   "groups":[2]
                },
                "name_regex":{
                   "regex":"([^(]*)(\\(IPa[^)]*\\))(.+)",
                   "groups":[1, 3]
                }
             }
          },
          "controlled_vocabularies":{
             "dcatapit_skos_theme_id":"theme.data-theme-skos",
             "dcatapit_skos_places_id":"theme.places-skos"
          }
       }
    }

* ``dataset_themes``: default value to use for the dataset themes field if the thesaurus keywords are missing in the ISO metadata. The source metadata should have thesaurus keywords from the EU controlled vocabulary (data-theme-skos.rdf). Multiple values must be set between braces and comma separated values.

* ``dataset_places``: default value to use for the dataset geographical name field if the thesaurus keywords are missing in the ISO metadata. The source metadata should have thesaurus keywords from the EU controlled vocabulary (places-skos.rdf). Multiple values must be set between braces and comma separated values.

* ``dataset_languages``: default value to use for the dataset languages field. Metadata languages are harvested by the che ckanext-spatial extension (see the 'dataset-language' in iso_values). Internally the harvester map the ISO languages to the mdr vocabulary languages. The default configuration for that can be overridden in harvest source configuration by using an additional configuration property, like::

        "mapping_languages_to_mdr_vocabulary": {
            "ita': "ITA",
            "ger': "DEU",
            "eng': "ENG"
        }
        
* ``frequency``: default value to use for the dataset frequency field. Metadata frequencies are harvested by the che ckanext-spatial extension (see the 'frequency-of-update' in iso_values). Internally the harvester automatically map the ISO frequencies to the mdr vocabulary frequencies.

* ``agents``: Configuration for harvesting the dcatapit dataset agents from the responsible party metadata element. Below more details on the agent configuration::

         "publisher":{
            "code":"p_bz",      --> the IPA/IVA code to use as default for the agent identifier
            "role":"publisher", --> the responsible party role to harvest for this agent
            "code_regex":{      --> a regular expression to extrapolate a substring from the responsible party organization name
               "regex":"\\(([^)]+)\\:([^)]+)\\)",
               "groups":[2]     --> optional, dependes by the regular expression
            },
            "name_regex":{      --> a regular expression to extrapolate the IPA/IVA code from the responsible party organization name
               "regex":"([^(]*)(\\(IPA[^)]*\\))(.+)",
               "groups":[1, 3]  --> optional, dependes by the regular expression
            }
         }
     
* ``controlled_vocabularies``: To harvest 'dataset_themes' and 'dataset_places' the harvester needs to know the thesaurus ID or TITLE as specified into the source metadata.

.. note:: The default IPA code to use is extrapolated by the metadata identifier in respect to the RNDT specifications (ipa_code:UUID). This represents a last fallback if the agent regex does not match any code and if the agent code has not been specified in configuration.

Harvest source configuration
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In order to set the dcatapit CSW harvester:

1. Specify a valid csw endpoint in the URL field 
2. Specify a title and a description for the harvest source
3. Select 'DCAT_AP-IT CSW Harvester' as source type
4. Provide your own configuration to override the default one

CSW Metadata Guidelines
^^^^^^^^^^^^^^^^^^^^^^^

* The dataset unique identifier will be harvested from the metadata fileIdentifier (see the above paragraph for additional notes about the IPA code).

* In order to harvest dcatapit dataset themes, the source metadata should have thesaurus keywords from the EU controlled vocabulary (data-theme-skos.rdf). Then the thesaurus identifier or title must be specified into the controlled_vocabularies->dcatapit_skos_theme_id configuration property

* In order to harvest dcatapit dataset geographical names, the source metadata should have thesaurus keywords from the EU controlled vocabulary (places-skos.rdf). Then the thesaurus identifier or title must be specified into the controlled_vocabularies->dcatapit_skos_places_id configuration property

* The dcatapit agents (publisher, holder, creator) will be harvested from the responsible party with the role specified in configuration (see 'agents' configuration property explained above)

* The dataset languages are harvested using the xpaths reported `into the ckanext-spatial harvested metadata file <https://github.com/ckan/ckanext-spatial/blob/master/ckanext/spatial/model/harvested_metadata.py#L723>`_

* The dataset frequency of update is harvested using the xpath reported `into the harvested metadata file <https://github.com/ckan/ckanext-spatial/blob/master/ckanext/spatial/model/harvested_metadata.py#L597>`_

Extending the package schema in your own extension
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. note:: This paragraph describes, if you want, how the package schema can be extended by your own ckan extension, leveraging on the ckanext-dcatapit functionalities.

The dcatapit extension allows to define additional custom fields to the package schema by implementing the `ICustomSchema` interface 
in you CKAN extension. Below a sample::

    class ExamplePlugin(plugins.SingletonPlugin):

        # ICustomSchema
        plugins.implements(interfaces.ICustomSchema)

        def get_custom_schema(self):
            return [
                {
                    'name': 'custom_text',
                    'validator': ['ignore_missing'],
                    'element': 'input',
                    'type': 'text',
                    'label': _('Custom Text'),
                    'placeholder': _('custom texte here'),
                    'is_required': False,
                    'localized': False
                }
            ]

Through this an additional schema field named `custom_text` will be added to the package schema and automatically managed by the dcatapit extension. Below a brief description of the fields properties that can be used:

* ``name``: the name of the field
* ``validator``: array of validators to use for the field
* ``element``: the element type to use into the package edit form (ie. see the available ckan macros or macros defined into the dcatapit extension `here <https://github.com/geosolutions-it/ckanext-dcatapit/blob/master/ckanext/dcatapit/templates/macros/dcatapit_form_macros.html>`_
* ``type``: the type of input eg. email, url, date (default: text)
* ``label``: the human readable label
* ``placeholder``: some placeholder text
* ``is_required``: boolean of whether this input is requred for the form to validate
* ``localized``: True to enable the field localization by the dcatapit extension (default False). This need the ckanext-multilang installed.

Managing translations
^^^^^^^^^^^^^^^^^^^^^

The dcatapit extension implements the ITranslation CKAN's interface so the translations procedure of the GUI elements is automatically covered using the translations files provided in the i18n directory.

.. note:: Pay attention that the usage of the ITranslation interface can work only in CKAN 2.5 or later, if you are using a minor version of CKAN the ITranslation's implementation will be ignored.

Creating a new translation
--------------------------

.. note:: The steps below can be used only if you have to update existing translations files.

To create a new translation proceed as follow:

1. Extract new messages from your extension updating the pot file::

		python setup.py extract_messages
     
2.  Create a translation file for your language (a po file) using the existing pot file in this plugin::

		python setup.py init_catalog --locale YOUR_LANGUAGE

Replace YOUR_LANGUAGE with the two-letter ISO language code (e.g. es, de).
     
3. Do the translation into the po file

4. Once the translation files (po) have been updated, either manually or via Transifex, compile them by running::

		python setup.py compile_catalog --locale YOUR_LANGUAGE
     
Updating an existing translation
--------------------------------

In order to update the existing translations proceed as follow:

1. Extract new messages from your extension updating the pot file::
	
		python setup.py extract_messages
     
2. Update the strings in your po file, while preserving your po edits, by doing::

		python setup.py update_catalog --locale YOUR-LANGUAGE

3. Once the translation files (po) have been updated adding the new translations needed, compile them by running::

		python setup.py compile_catalog --locale YOUR_LANGUAGE
		

