<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:gml="http://www.opengis.net/gml"
    xmlns:srv="http://www.isotc211.org/2005/srv" 
    xmlns:gmx="http://www.isotc211.org/2005/gmx"
    xmlns:gco="http://www.isotc211.org/2005/gco" 
    xmlns:gmd="http://www.isotc211.org/2005/gmd"
    xmlns:xlink="http://www.w3.org/1999/xlink" 
    exclude-result-prefixes="#all">

    <xsl:output indent="yes"/>

    <!-- XSL di importazione di metadati ISO in RNDT 
        == Imposta gmd:metadataStandardName e gmd:metadataStandardVersion per identificare lo schema iso19139.rndt 
        == Aggiunge codice IPA come prefisso al fileIdentifier 
        == Rimuove parentIdentifier
        == Imposta resourceId come ipa:fileidentifier_resource  
        == Imposta gmd:series/gmd:CI_Series/gmd:issueIdentification come ipa:parentidentifier_resource oppure ipa:fileidentifier_resource   
    -->

    <xsl:variable name="IPA" select="'cmfi'" />

    <xsl:variable name="fileId"    select="//gmd:MD_Metadata/gmd:fileIdentifier/gco:CharacterString/text()" />
    <xsl:variable name="parentId"  select="//gmd:MD_Metadata/gmd:parentIdentifier/gco:CharacterString/text()" />
    <xsl:variable name="newFileId" select="concat($IPA,':',$fileId)" />
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>

    <!-- Blocco MD_Metadata
         == Elimina parentId
         == Imposta metadata name e version
    -->
    <xsl:template match="gmd:MD_Metadata">

        <xsl:message>.</xsl:message>
        <xsl:message>====== IMPORTAZIONE METADATO <xsl:value-of select="$fileId"/></xsl:message>

        <!-- Log su POC non valido -->
        <xsl:if test="not(gmd:contact/gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode/@codeListValue='pointOfContact')">
            <xsl:message>==== Errore: PoC metadato non trovato</xsl:message>
        </xsl:if>    

    
        <xsl:copy>
            <gmd:fileIdentifier>
                <gco:CharacterString><xsl:value-of select="$newFileId"/></gco:CharacterString>
            </gmd:fileIdentifier>
            <xsl:apply-templates select="gmd:language" />
            <xsl:apply-templates select="gmd:characterSet" />            
            <gmd:parentIdentifier gco:nilReason="missing">
                <gco:CharacterString/>
            </gmd:parentIdentifier>
            <xsl:apply-templates select="gmd:hierarchyLevel" />
            <xsl:apply-templates select="gmd:hierarchyLevelName" />
            <xsl:apply-templates select="gmd:contact" />
            <xsl:apply-templates select="gmd:dateStamp" />
            
            <gmd:metadataStandardName>
                <gco:CharacterString>DM - Regole tecniche RNDT</gco:CharacterString>
            </gmd:metadataStandardName>
            <gmd:metadataStandardVersion>
                <gco:CharacterString>10 novembre 2011</gco:CharacterString>
            </gmd:metadataStandardVersion>

            <xsl:apply-templates select="gmd:dataSetURI" />
            <xsl:apply-templates select="gmd:locale" />
            <xsl:apply-templates select="gmd:spatialRepresentationInfo" />
            <xsl:apply-templates select="gmd:referenceSystemInfo" />
            <xsl:apply-templates select="gmd:metadataExtensionInfo" />
            <xsl:apply-templates select="gmd:identificationInfo" />
            <xsl:apply-templates select="gmd:contentInfo" />
            <xsl:apply-templates select="gmd:distributionInfo" />
            <xsl:choose>
                <xsl:when test="gmd:dataQualityInfo">
                    <xsl:apply-templates select="gmd:dataQualityInfo" />                
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="dataQualityInfoSnippet"/>                                            
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="gmd:portrayalCatalogueInfo" />
            <xsl:apply-templates select="gmd:metadataConstraints" />
            <xsl:apply-templates select="gmd:applicationSchemaInfo" />
            <xsl:apply-templates select="gmd:metadataMaintenance" />

        </xsl:copy>
    </xsl:template>


    <!-- Remove original metadataStandardName and metadataStandardVersion -->
    <xsl:template match="gmd:metadataStandardName"/>
    <xsl:template match="gmd:metadataStandardVersion"/>

    <!-- Blocco CI_CItation
        == Imposta resourceId
        == Imposta issueId
    -->
    <xsl:template match="//gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation">
    
        <xsl:variable name="newseriesid">
            <xsl:choose>
                <xsl:when test="$parentId"><xsl:value-of select="concat($IPA,':',$parentId,'_resource')"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="concat($IPA,':',$fileId,'_resource')"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
    
        <xsl:copy>
            <xsl:apply-templates select="gmd:title" />
            <xsl:apply-templates select="gmd:alternateTitle" />
            <xsl:apply-templates select="gmd:date" />
            <xsl:apply-templates select="gmd:edition" />
            <xsl:apply-templates select="gmd:editionDate" />
            
            <gmd:identifier>
                <gmd:MD_Identifier>
                    <gmd:code>
                        <gco:CharacterString><xsl:value-of select="concat($IPA,':',$fileId,'_resource')"/></gco:CharacterString>
                    </gmd:code>
                </gmd:MD_Identifier>
            </gmd:identifier>

            <xsl:choose>
                <xsl:when test="gmd:citedResponsibleParty">
                    <xsl:apply-templates select="gmd:citedResponsibleParty" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="inferCitedResponsibleParty"/>
                </xsl:otherwise>
            </xsl:choose>

            <xsl:apply-templates select="gmd:presentationForm" />
            
            <gmd:series>
                <gmd:CI_Series>
                    <gmd:issueIdentification>
                        <gco:CharacterString><xsl:value-of select="normalize-space($newseriesid)"/></gco:CharacterString>
                    </gmd:issueIdentification>                        
                </gmd:CI_Series>
            </gmd:series>            
            
            <xsl:apply-templates select="gmd:otherCitationDetails" />
            <xsl:apply-templates select="gmd:collectiveTitle" />
            <xsl:apply-templates select="gmd:ISBN" />
            <xsl:apply-templates select="gmd:ISSN" />    
        </xsl:copy>    
    </xsl:template>
    
    <!-- Modifica i link alle risorse interne, usando il nuovo fileId  
        es: http://dati.provincia.fi.it/geonetwork/srv/en/resources.get?uuid=287beb31-31b9-44cc-86e3-6b179bb9bbdc&amp;fname=PTC_appendici.zip&amp;access=private
    -->
    
    <xsl:template match="gmd:CI_OnlineResource/gmd:linkage/gmd:URL[contains(text(), $fileId)]" priority="10">
        <xsl:copy>
            <xsl:value-of select="replace(text(), $fileId, $newFileId)"/>
        </xsl:copy>
    </xsl:template>        

    <!--  modifica il link alle risorse correlate, valore da verificare -->
    
    <xsl:template match="gmd:CI_OnlineResource/gmd:linkage/gmd:URL[contains(text(), 'uuid=')]">
        <xsl:message>==== Rimappaggio linkage <xsl:value-of select="text()"/></xsl:message>
        <xsl:copy>
            <xsl:value-of select="replace(text(), 'uuid=', concat('uuid=', $IPA, ':'))"/>
        </xsl:copy>
    </xsl:template>        

    <!--  modifica il link dei filename, valore da verificare -->

    <xsl:template match="gmd:fileName/gco:CharacterString[contains(text(), 'uuid=')]">
        <xsl:message>==== Rimappaggio filename <xsl:value-of select="text()"/></xsl:message>
        <xsl:copy>
            <xsl:value-of select="replace(text(), 'uuid=', concat('uuid=', $IPA, ':'))"/>
        </xsl:copy>
    </xsl:template>        
                              
    <!-- Imposta i codeList richiesti, e i text() interni se mancanti -->

    <xsl:template match="gmd:LanguageCode[@codeListValue]" priority="10">
        <gmd:LanguageCode codeList="http://www.loc.gov/standards/iso639-2/">
            <xsl:apply-templates select="@*[name(.)!='codeList']"/>

            <!-- add a node text-->
            <xsl:choose>            
                <xsl:when test="not(text())">
                    <xsl:value-of select="@codeListValue"/>            
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="node()" />
                </xsl:otherwise>
            </xsl:choose>
        </gmd:LanguageCode>
    </xsl:template>

    <xsl:template match="gmd:*[@codeListValue]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="codeList">
                <xsl:value-of select="concat('http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#',local-name(.))"/>
            </xsl:attribute>

            <!-- add a node text-->
            <xsl:choose>            
                <xsl:when test="not(text())">
                    <xsl:value-of select="@codeListValue"/>            
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="node()" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>                
    
    <!-- CRS EPSG -->
    <xsl:template match="gmd:referenceSystemInfo[gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier/gmd:codeSpace/gco:CharacterString/text()='EPSG']" priority="10">

        <xsl:variable name="code"  select="gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier/gmd:code/gco:CharacterString/text()" />    
        <xsl:variable name="epsgcode" select="substring-before(substring-after($code,'(EPSG:'), ')')" />
        <xsl:variable name="rndtcode"><xsl:call-template name="mapEPSGtoRNDT"><xsl:with-param name="epsg" select="$epsgcode"/></xsl:call-template></xsl:variable>
        
        <xsl:choose>
            <!-- Controlla se esiste un codice RNDT relativo al codice EPSG -->
            <xsl:when test="$rndtcode">
                <xsl:message>== CRS EPSG: RNDT <xsl:value-of select="$rndtcode"/></xsl:message>
                <xsl:call-template name="srsRNDTsnippet"><xsl:with-param name="rndt" select="$rndtcode"/></xsl:call-template>                            
            </xsl:when>
            <xsl:when test="$epsgcode">
                <xsl:message>== CRS EPSG: EPSG <xsl:value-of select="$epsgcode"/></xsl:message>            
                <xsl:call-template name="srsEPSGsnippet"><xsl:with-param name="epsg" select="$epsgcode"/></xsl:call-template>                            
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>==== CRS EPSG: CODICE NON PARSABILE <xsl:value-of select="$code"/></xsl:message>
                <xsl:call-template name="srsEPSGsnippet"><xsl:with-param name="epsg" select="'4326'"/></xsl:call-template>                                        
            </xsl:otherwise>            
        </xsl:choose>            
    </xsl:template>

    <!-- CRS altri -->
    <xsl:template match="gmd:referenceSystemInfo">

        <xsl:variable name="code"  select="gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier/gmd:code/gco:CharacterString/text()" />    
        <xsl:variable name="epsgcode" select="substring-before(substring-after($code,'(EPSG:'), ')')" />
        <xsl:variable name="rndtcode"><xsl:call-template name="mapEPSGtoRNDT"><xsl:with-param name="epsg" select="$epsgcode"/></xsl:call-template></xsl:variable>
        
        <xsl:choose>
            <!-- Controlla se esiste un codice RNDT relativo al codice EPSG -->
            <xsl:when test="$rndtcode">
                <xsl:message>== CRS: RNDT <xsl:value-of select="$rndtcode"/></xsl:message>
                <xsl:call-template name="srsRNDTsnippet"><xsl:with-param name="rndt" select="$rndtcode"/></xsl:call-template>                            
            </xsl:when>
            <xsl:when test="$epsgcode">
                <xsl:message>== CRS: EPSG <xsl:value-of select="$epsgcode"/></xsl:message>            
                <xsl:call-template name="srsEPSGsnippet"><xsl:with-param name="epsg" select="$epsgcode"/></xsl:call-template>                            
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>==== CRS: CODICE NON PARSABILE <xsl:value-of select="$code"/></xsl:message>
                <xsl:call-template name="srsEPSGsnippet"><xsl:with-param name="epsg" select="'4326'"/></xsl:call-template>                                        
            </xsl:otherwise>            
        </xsl:choose>            
    </xsl:template>

    <xsl:template name="srsRNDTsnippet">
        <xsl:param name="rndt"/>
    
        <gmd:referenceSystemInfo>
            <gmd:MD_ReferenceSystem>
                <gmd:referenceSystemIdentifier>
                    <gmd:RS_Identifier>
                        <gmd:code>
                            <gco:CharacterString><xsl:value-of select="$rndt"/></gco:CharacterString>
                        </gmd:code>
                    </gmd:RS_Identifier>
                </gmd:referenceSystemIdentifier>
            </gmd:MD_ReferenceSystem>
        </gmd:referenceSystemInfo>
    </xsl:template>            
    
    <xsl:template name="srsEPSGsnippet">
        <xsl:param name="epsg"/>
    
        <gmd:referenceSystemInfo>
            <gmd:MD_ReferenceSystem>
                <gmd:referenceSystemIdentifier>
                    <gmd:RS_Identifier>
                        <gmd:code>
                            <gco:CharacterString><xsl:value-of select="@epsg"/></gco:CharacterString>
                        </gmd:code>
                        <gmd:codeSpace>
                            <gco:CharacterString>http://www.epsg-registry.org/</gco:CharacterString>
                        </gmd:codeSpace>                        
                    </gmd:RS_Identifier>
                </gmd:referenceSystemIdentifier>
            </gmd:MD_ReferenceSystem>
        </gmd:referenceSystemInfo>
    </xsl:template>            


    <xsl:template name="mapEPSGtoRNDT">
        <xsl:param name="epsg"/>
        
        <xsl:choose>
            <xsl:when test="$epsg='4326'">WGS84</xsl:when>
            <xsl:when test="$epsg='4258'">ETRS89</xsl:when>
            <xsl:when test="$epsg='3035'">ETRS89/ETRS-LAEA</xsl:when>
            <xsl:when test="$epsg='3034'">ETRS89/ETRS-LCC</xsl:when>
            <xsl:when test="$epsg='3044'">ETRS89/ETRS-TM32</xsl:when>
            <xsl:when test="$epsg='3045'">ETRS89/ETRS-TM33</xsl:when>
            <xsl:when test="$epsg='3004'">ROMA40/EST</xsl:when>
            <xsl:when test="$epsg='3003'">ROMA40/OVEST</xsl:when>
            <xsl:when test="$epsg='23032'">ED50/UTM 32N</xsl:when>
            <xsl:when test="$epsg='23033'">ED50/UTM 33N</xsl:when>
            <xsl:when test="$epsg='3064'">IGM95/UTM 32N</xsl:when>
            <xsl:when test="$epsg='3065'">IGM95/UTM 33N</xsl:when>
            <xsl:when test="$epsg='32632'">WGS84/UTM 32N</xsl:when>
            <xsl:when test="$epsg='32633'">WGS84/UTM 33N</xsl:when>
            <xsl:when test="$epsg='32634'">WGS84/UTM 34N</xsl:when>
            <xsl:when test="$epsg='4265'">ROMA40</xsl:when>
            <xsl:when test="$epsg='4806'">ROMA40/ROMA</xsl:when>
            <xsl:when test="$epsg='4230'">ED50</xsl:when>
            <xsl:when test="$epsg='4670'">IGM95</xsl:when>
            <xsl:when test="$epsg='4979'">WGS84/3D</xsl:when>
            <xsl:when test="$epsg='25832'">ETRS89/UTM-zone32N</xsl:when>
            <xsl:when test="$epsg='25833'">ETRS89/UTM-zone33N</xsl:when>
        </xsl:choose>    
    </xsl:template>  
              
    <!-- Imposta spatialRepresentationType -->
    
    <xsl:template match="gmd:MD_DataIdentification">
        <xsl:copy>
            <xsl:apply-templates select="gmd:citation" />
            <xsl:apply-templates select="gmd:abstract" />
            <xsl:apply-templates select="gmd:purpose" />
            <xsl:apply-templates select="gmd:credit" />
            <xsl:apply-templates select="gmd:status" />
            <xsl:apply-templates select="gmd:pointOfContact" />
            <xsl:apply-templates select="gmd:resourceMaintenance" />
            <xsl:apply-templates select="gmd:graphicOverview" />
            <xsl:apply-templates select="gmd:resourceFormat" />
            <xsl:apply-templates select="gmd:descriptiveKeywords" />
            <xsl:apply-templates select="gmd:resourceSpecificUsage" />
            <xsl:apply-templates select="gmd:resourceConstraints" />
            <xsl:apply-templates select="gmd:aggregationInfo" />
            <!-- ^^ end of abstract identification ^^ -->

            <xsl:choose>
                <xsl:when test="gmd:spatialRepresentationType">
                    <xsl:apply-templates select="gmd:spatialRepresentationType" />            
                </xsl:when>
                <xsl:otherwise>
        			<gmd:spatialRepresentationType>
                        <gmd:MD_SpatialRepresentationTypeCode 
                            codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/ML_gmxCodelists.xml#MD_SpatialRepresentationTypeCode"
                            codeListValue="vector">vector</gmd:MD_SpatialRepresentationTypeCode>
                    </gmd:spatialRepresentationType>
                </xsl:otherwise>
            </xsl:choose>
            
            <xsl:apply-templates select="gmd:spatialResolution" />
            <xsl:apply-templates select="gmd:language" />
            <xsl:apply-templates select="gmd:characterSet" />
            <xsl:apply-templates select="gmd:topicCategory" />
            <xsl:apply-templates select="gmd:environmentDescription" />
            <xsl:apply-templates select="gmd:extent" />
            <xsl:apply-templates select="gmd:supplementalInformation" />
        
        </xsl:copy>
    </xsl:template>
        

    <xsl:template match="gmd:dataQualityInfo/gmd:DQ_DataQuality">
    
        <xsl:copy>
            <xsl:apply-templates select="gmd:scope" />
            <xsl:apply-templates select="gmd:report" />
            
            <!-- Aggiunge accuratezza posizionale se manca -->
            <xsl:if test="not(gmd:report/gmd:DQ_AbsoluteExternalPositionalAccuracy)">
                <xsl:call-template name="report_absoluteExternalPositionalAccuracySnippet"/>
            </xsl:if>

            <!-- Aggiunge RNDT conformance se manca -->
            <xsl:if test="not(contains(gmd:result/gmd:DQ_ConformanceResult/gmd:specification/gmd:CI_Citation/gmd:title/gco:CharacterString/text(),'1089'))">
                <xsl:call-template name="report_domainConsistencyRNDTSnippet"/>
            </xsl:if>

            <xsl:apply-templates select="gmd:lineage" />            
        </xsl:copy>    
    
    </xsl:template>
                  
    <xsl:template name="dataQualityInfoSnippet">
    
        <xsl:message>== Aggiunta snippet gmd:dataQualityInfo</xsl:message>
        
        <gmd:dataQualityInfo>
            <gmd:DQ_DataQuality>
                <gmd:scope>
                    <gmd:DQ_Scope>
                        <gmd:level>
                            <gmd:MD_ScopeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/gmxCodelists.xml#CI_ScopeCode" codeListValue="dataset">dataset</gmd:MD_ScopeCode>
                        </gmd:level>
                    </gmd:DQ_Scope>
                </gmd:scope>

                <xsl:call-template name="report_domainConsistencyRNDTSnippet"/>

                <xsl:call-template name="report_absoluteExternalPositionalAccuracySnippet"/>
                                
                <gmd:lineage>
                    <gmd:LI_Lineage>
                        <gmd:statement>
                            <gco:CharacterString>Descrizione della provenienza e del processo di produzione del dato (storia, ciclo di vita, rilevazione, acquisizione, forma attuale, qualità richiesta per garantirne l'interoperabilità)</gco:CharacterString>
                        </gmd:statement>
                    </gmd:LI_Lineage>
                </gmd:lineage>
            </gmd:DQ_DataQuality>
        </gmd:dataQualityInfo>
    </xsl:template>            
                  
    <xsl:template name="report_absoluteExternalPositionalAccuracySnippet">
                <gmd:report>
                    <gmd:DQ_AbsoluteExternalPositionalAccuracy>
                        <gmd:result>
                            <gmd:DQ_QuantitativeResult>
                                <gmd:valueUnit>
                                    <gml:BaseUnit gml:id="m">
                                        <gml:identifier codeSpace="http://www.bipm.fr/en/si/base_units">m</gml:identifier>
                                        <gml:unitsSystem xlink:href="http://www.bipm.fr/en/si"/>
                                    </gml:BaseUnit>
                                </gmd:valueUnit>
                                <gmd:value>
                                    <gco:Record>
                                        <gco:Real>0</gco:Real>
                                    </gco:Record>
                                </gmd:value>
                            </gmd:DQ_QuantitativeResult>
                        </gmd:result>
                    </gmd:DQ_AbsoluteExternalPositionalAccuracy>
                </gmd:report>    
    </xsl:template>

    <xsl:template name="report_domainConsistencyRNDTSnippet">
                <gmd:report>                                
                    <gmd:DQ_DomainConsistency>
                        <gmd:result>
                            <gmd:DQ_ConformanceResult>
                                <gmd:specification>
                                    <gmd:CI_Citation>
                                        <gmd:title>
                                            <gco:CharacterString>REGOLAMENTO (UE) N. 1089/2010 DELLA COMMISSIONE del 23 novembre 2010 recante attuazione della direttiva 2007/2/CE del Parlamento europeo e del Consiglio per quanto riguarda l'interoperabilità dei set di dati territoriali e dei servizi di dati territoriali</gco:CharacterString>
                                        </gmd:title>
                                        <gmd:date>
                                            <gmd:CI_Date>
                                                <gmd:date>
                                                    <gco:Date>2010-12-08</gco:Date>
                                                </gmd:date>
                                                <gmd:dateType>
                                                    <gmd:CI_DateTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/gmxCodelists.xml#CI_DateTypeCode" codeListValue="publication">Pubblicazione</gmd:CI_DateTypeCode>
                                                </gmd:dateType>
                                            </gmd:CI_Date>
                                        </gmd:date>
                                    </gmd:CI_Citation>
                                </gmd:specification>
                                <gmd:explanation>
                                    <gco:CharacterString>non valutato</gco:CharacterString>
                                </gmd:explanation>
                                <gmd:pass gco:nilReason="unknown"/>
                            </gmd:DQ_ConformanceResult>
                        </gmd:result>
                    </gmd:DQ_DomainConsistency>
                </gmd:report>    
    </xsl:template>

    <!-- Elimina poc con ruolo=distributor dall'identificationInfo 
         e sposta in distributionInfo -->
    <xsl:template match="gmd:identificationInfo/*/gmd:pointOfContact[gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode/@codeListValue='distributor']">
        <!-- elimina nel match normale-->
    </xsl:template>        

    <!--  template per copiare il distributor in distributorInfo -->
    <xsl:template match="gmd:identificationInfo/*/gmd:pointOfContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue='distributor']" mode="copy">

        <xsl:message>== Spostamento distributor</xsl:message>
        <gmd:distributor>
            <gmd:MD_Distributor>
                <gmd:distributorContact>
                    <xsl:copy>
                        <xsl:apply-templates select="@*|node()" />
                    </xsl:copy>
                </gmd:distributorContact>
            </gmd:MD_Distributor>
        </gmd:distributor>        
    </xsl:template>        

    <xsl:template match="gmd:distributionInfo/gmd:MD_Distribution">
        <xsl:copy>
            <xsl:apply-templates select="gmd:distributionFormat" />
            <xsl:apply-templates select="gmd:distributor" />
    
            <xsl:choose>
                <!--  se esiste, copia id distributor dall'identificationInfo -->
                <xsl:when test="../../gmd:identificationInfo/*/gmd:pointOfContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue='distributor']">
                   <xsl:apply-templates select="../../gmd:identificationInfo/*/gmd:pointOfContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue='distributor']" mode="copy"/>                
                </xsl:when>
                <!-- altrimenti, se nessun distributor è specificato in distributorInfo, copia il contact del metadato. Poco corretto, ma questo abbiamo. -->
                <xsl:when test="not(gmd:distributor)">
                    <xsl:message>==== FORZA POC COME DISTRIBUTOR </xsl:message>
                    <gmd:distributor>
                        <gmd:MD_Distributor>
                            <gmd:distributorContact>
                                <xsl:apply-templates select="(../../gmd:contact/gmd:CI_ResponsibleParty)[1]"/>
                            </gmd:distributorContact>
                        </gmd:MD_Distributor>
                    </gmd:distributor>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message>== Usa distributor esistente</xsl:message>                
                </xsl:otherwise>            
            </xsl:choose>
        
            <xsl:apply-templates select="gmd:transferOptions" />

        </xsl:copy>        
    </xsl:template>

    <!-- citedResponsibleParty -->

    <xsl:template name="inferCitedResponsibleParty">
        <gmd:citedResponsibleParty>

            <xsl:choose>
                <!--  se esiste, copia id distributor dall'identificationInfo -->

                <xsl:when test="../../gmd:pointOfContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue='custodian']">
                   <xsl:message>== Copia citedResponsibleParty da custodian</xsl:message>
                   <xsl:apply-templates select="../../gmd:pointOfContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue='custodian']"/>
                </xsl:when>
                <xsl:when test="../../gmd:pointOfContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue='distributor']">
                   <xsl:message>== Copia citedResponsibleParty da distributor</xsl:message>
                   <xsl:apply-templates select="../../gmd:pointOfContact/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue='distributor']" mode="copy"/>
                </xsl:when>
                <xsl:when test="../../gmd:pointOfContact/gmd:CI_ResponsibleParty[1]">
                   <xsl:message>== Copia citedResponsibleParty da pointOfContact[1]</xsl:message>
                   <xsl:apply-templates select="../../gmd:pointOfContact/gmd:CI_ResponsibleParty[1]"/>
                </xsl:when>
                <xsl:when test="../../../../../gmd:contact/gmd:CI_ResponsibleParty">
                   <xsl:message>== Copia citedResponsibleParty dal contact</xsl:message>
                   <xsl:apply-templates select="../../../../../gmd:contact/gmd:CI_ResponsibleParty"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message>==== ATTENZIONE A citedResponsibleParty</xsl:message>
                </xsl:otherwise>
            </xsl:choose>
        </gmd:citedResponsibleParty>
    </xsl:template>


    <!-- Fixa la gmd:date del thesaurus -->
        
    <xsl:template match="gmd:thesaurusName/gmd:CI_Citation[not(gmd:date/gmd:CI_Date/gmd:date/gco:Date/text())]">
        <xsl:copy>
            <xsl:apply-templates select="gmd:title" />
            <xsl:apply-templates select="gmd:alternateTitle" />
            
            <gmd:date>
                <gmd:CI_Date>
                    <gmd:date>
                        <gco:Date><xsl:value-of select="gmd:editionDate/gco:Date/text()"/></gco:Date>
                    </gmd:date>
                    <gmd:dateType>
                        <gmd:CI_DateTypeCode codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/codelist/gmxCodelists.xml#CI_DateTypeCode" codeListValue="publication">pubblicazione</gmd:CI_DateTypeCode>
                    </gmd:dateType>
                </gmd:CI_Date>
            </gmd:date>

            <xsl:apply-templates select="child::* except (gmd:title|gmd:alternateTitler|gmd:date)"/>            
        </xsl:copy>
    </xsl:template>
    

    <!-- Trasforma il datestamp da DateTime a Date come richiesto da RNDT -->
    
    <xsl:template match="gmd:dateStamp[gco:DateTime]">
        <xsl:copy>
            <gco:Date>
                <xsl:value-of select="substring-before(gco:DateTime/text(), 'T')"/>
            </gco:Date>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date[gco:DateTime]">
        <xsl:copy>
            <gco:Date>
                <xsl:value-of select="substring-before(gco:DateTime/text(), 'T')"/>
            </gco:Date>
        </xsl:copy>
    </xsl:template>
    
    <!-- Rimuove gli initiativeType senza valore assegnato -->
    <xsl:template match="gmd:initiativeType[gmd:DS_InitiativeTypeCode/@codeListValue='']">
        <xsl:message>== Eliminazione initiativeType vuoto</xsl:message>    
    </xsl:template>    
       
    <!-- Log su aggregation non valida -->
    <xsl:template match="gmd:MD_AggregateInformation[not(gmd:aggregateDataSetName or gmd:aggregateDataSetIdentifier)]">
        <xsl:message>==== Errore di compilazione in AggregateInformation</xsl:message>    
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
        
    </xsl:template>
            
</xsl:stylesheet>