.. _mappinglicenses:

Mapping licenses
################

The ISO19139 field that is used to express the license in CKAN is the one    
displayed in GeoNetwork as "Resource constraint" (*Italian labels: "Vincoli sulla risorsa"/"Limitazione d'uso"*). 

This field is a free text, that needs to have one of these values to be properly parsed by CKAN: 

+----------------+-----------------------------------------------------+
| String         | Open License                                        |
+================+=====================================================+
| ``odc-pddl``   | - LicenseOpenDataCommonsPDDL                        |
|                | - http://opendatacommons.org/licenses/pddl/         |
+----------------+-----------------------------------------------------+
| ``odc-odbl``   | - LicenseOpenDataCommonsOpenDatabase                |
|                | - http://opendatacommons.org/licenses/odbl/         |
+----------------+-----------------------------------------------------+
| ``odc-by``     | - LicenseOpenDataAttribution                        |
|                | - http://opendatacommons.org/licenses/by/           |
+----------------+-----------------------------------------------------+
| ``cc-zero``    | - LicenseCreativeCommonsZero                        |
|                | - http://creativecommons.org/publicdomain/zero/1.0/ |
+----------------+-----------------------------------------------------+
| ``cc-by``      | - LicenseCreativeCommonsAttribution                 |
|                | - http://creativecommons.org/licenses/by/3.0/       |
+----------------+-----------------------------------------------------+
| ``cc-by-sa``   | - LicenseCreativeCommonsAttributionShareAlike       |
|                | - http://creativecommons.org/licenses/by-sa/3.0/    |
+----------------+-----------------------------------------------------+
| ``gfdl``       | - LicenseGNUFreeDocument                            |
|                | - http://www.gnu.org/copyleft/fdl.html              |
+----------------+-----------------------------------------------------+
| ``other-open`` | LicenseOtherOpen                                    |
|                |                                                     |
+----------------+-----------------------------------------------------+
| ``other-pd``   | LicenseOtherPublicDomain                            |
|                |                                                     |
+----------------+-----------------------------------------------------+
| ``other-at``   | LicenseOtherAttribution                             |
|                |                                                     |
+----------------+-----------------------------------------------------+
| ``uk-ogl``     | LicenseOpenGovernment                               |
|                |                                                     |
+----------------+-----------------------------------------------------+

These are the values for the recognised non-open licenses:

+------------------+--------------------------------------------------+
| String           | Non-open License                                 |
+==================+==================================================+
| ``cc-nc``        | - LicenseCreativeCommonsNonCommercial            |
|                  | - http://creativecommons.org/licenses/by-nc/2.5/ |
+------------------+--------------------------------------------------+
| ``other-nc``     | LicenseOtherNonCommercial                        |
|                  |                                                  |
+------------------+--------------------------------------------------+
| ``other-closed`` | LicenseOtherClosed                               |
|                  |                                                  |
+------------------+--------------------------------------------------+

Values different from these ones will be handled as non-recognized closed licenses.


