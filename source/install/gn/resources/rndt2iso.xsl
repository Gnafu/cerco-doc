<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:gml="http://www.opengis.net/gml"
    xmlns:srv="http://www.isotc211.org/2005/srv" 
    xmlns:gmx="http://www.isotc211.org/2005/gmx"
    xmlns:gco="http://www.isotc211.org/2005/gco" 
    xmlns:gmd="http://www.isotc211.org/2005/gmd"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:csw="http://www.opengis.net/cat/csw/2.0.2"
    exclude-result-prefixes="#all">

    <xsl:output indent="yes"/>
    
    <!-- skip elements in non-copy mode -->
    <xsl:template match="@*|node()">
      <xsl:apply-templates select="@*|node()" />
    </xsl:template>
    
    <!--  enter copy mode when first CSW element is found -->   
    <xsl:template match="*[namespace-uri()='http://www.opengis.net/cat/csw/2.0.2']">
       <xsl:copy>
           <xsl:apply-templates select="@*|node()" mode="copy"/>         
       </xsl:copy>
    </xsl:template>
   
    <!-- copy elements in copy mode -->
    <xsl:template match="@*|node()" mode="copy">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="copy"/>
        </xsl:copy>
    </xsl:template>
   
   <!-- ResourceId e issueId rappresentano la vera gerarchia dei dati -->
    <xsl:variable name="resId"
         select="//gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:identifier/gmd:RS_Identifier/gmd:code/gco:CharacterString/text()" />
    <xsl:variable name="serieId"
         select="//gmd:series/gmd:CI_Series/gmd:issueIdentification/gco:CharacterString/text()" />


    <!-- Blocco MD_Metadata
         == Imposta parentId se serve
         == Imposta metadata name e version
    -->
    <xsl:template match="gmd:MD_Metadata" mode="copy">
        <xsl:copy>
            <!-- process fileId in its own template -->
            <xsl:apply-templates select="gmd:fileIdentifier" mode="copy"/>   
            <xsl:apply-templates select="gmd:language"       mode="copy"/>
            <xsl:apply-templates select="gmd:characterSet"   mode="copy"/>

            <xsl:if test="$resId != $serieId">
                <!-- parte di un gerarchia: ricaviamo il parent dal serieId -->
                <xsl:variable name="parentId" select="substring-before($serieId,'_resource')" />
                <gmd:parentIdentifier>
                    <gco:CharacterString><xsl:value-of select="$parentId"/></gco:CharacterString>
                </gmd:parentIdentifier>
            </xsl:if>
            
            <xsl:apply-templates select="gmd:hierarchyLevel"     mode="copy"/>
            <xsl:apply-templates select="gmd:hierarchyLevelName" mode="copy"/>
            <xsl:apply-templates select="gmd:contact"            mode="copy"/>
            <xsl:apply-templates select="gmd:dateStamp"          mode="copy" />
            
            <gmd:metadataStandardName>
                <gco:CharacterString>ISO 19115:2003/19139</gco:CharacterString>
            </gmd:metadataStandardName>
            <gmd:metadataStandardVersion>
                <gco:CharacterString>1.0</gco:CharacterString>
            </gmd:metadataStandardVersion>

            <xsl:apply-templates
                select="child::* except (gmd:fileIdentifier|gmd:language|gmd:characterSet|gmd:parentIdentifier|gmd:hierarchyLevel|gmd:hierarchyLevelName|gmd:contact|gmd:dateStamp)" 
                mode="copy"/>
        </xsl:copy>
    </xsl:template>


   <!-- Remove original metadataStandardName and metadataStandardVersion. -->
   <xsl:template match="gmd:metadataStandardName"    mode="copy"/>
   <xsl:template match="gmd:metadataStandardVersion" mode="copy"/>

</xsl:stylesheet>