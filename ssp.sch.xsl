<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:array="http://www.w3.org/2005/xpath-functions/array"
                xmlns:f="https://fedramp.gov/ns/oscal"
                xmlns:fedramp="https://fedramp.gov/ns/oscal"
                xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                xmlns:lv="local-validations"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:schold="http://www.ascc.net/xml/schematron"
                xmlns:unit="http://us.gov/testing/unit-testing"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0"><!--Implementers: please note that overriding process-prolog or process-root is 
    the preferred method for meta-stylesheets to use where possible. -->
   <xsl:param name="archiveDirParameter"/>
   <xsl:param name="archiveNameParameter"/>
   <xsl:param name="fileNameParameter"/>
   <xsl:param name="fileDirParameter"/>
   <xsl:variable name="document-uri">
      <xsl:value-of select="document-uri(/)"/>
   </xsl:variable>
   <!--PHASES-->
   <!--PROLOG-->
   <xsl:output xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
               method="xml"
               omit-xml-declaration="no"
               standalone="yes"
               indent="yes"/>
   <!--XSD TYPES FOR XSLT2-->
   <!--KEYS AND FUNCTIONS-->
   <xsl:function xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
                 xmlns:feddoc="http://us.gov/documentation/federal-documentation"
                 xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="lv:if-empty-default">
      <xsl:param name="item"/>
      <xsl:param name="default"/>
      <xsl:choose>
         <xsl:when test="$item instance of xs:untypedAtomic or $item instance of xs:anyURI or $item instance of xs:string or $item instance of xs:QName or $item instance of xs:boolean or $item instance of xs:base64Binary or $item instance of xs:hexBinary or $item instance of xs:integer or $item instance of xs:decimal or $item instance of xs:float or $item instance of xs:double or $item instance of xs:date or $item instance of xs:time or $item instance of xs:dateTime or $item instance of xs:dayTimeDuration or $item instance of xs:yearMonthDuration or $item instance of xs:duration or $item instance of xs:gMonth or $item instance of xs:gYear or $item instance of xs:gYearMonth or $item instance of xs:gDay or $item instance of xs:gMonthDay">
            <xsl:value-of select="                         if ($item =&gt; string() =&gt; normalize-space() eq '') then                             $default                         else                             $item"/>
         </xsl:when>
         <xsl:when test="$item instance of element() or $item instance of attribute() or $item instance of text() or $item instance of node() or $item instance of document-node() or $item instance of comment() or $item instance of processing-instruction()">
            <xsl:sequence select="                         if ($item =&gt; normalize-space() =&gt; not()) then                             $default                         else                             $item"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:sequence select="()"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
                 xmlns:feddoc="http://us.gov/documentation/federal-documentation"
                 xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 as="item()*"
                 name="lv:registry">
      <xsl:sequence select="$registry"/>
   </xsl:function>
   <xsl:function xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
                 xmlns:feddoc="http://us.gov/documentation/federal-documentation"
                 xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 as="xs:string"
                 name="lv:sensitivity-level">
      <xsl:param as="node()*" name="context"/>
      <xsl:value-of select="$context//oscal:security-sensitivity-level"/>
   </xsl:function>
   <xsl:function xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
                 xmlns:feddoc="http://us.gov/documentation/federal-documentation"
                 xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 as="document-node()*"
                 name="lv:profile">
      <xsl:param name="level" required="true"/>
      <xsl:variable name="profile-map">
         <profile href="{concat($baselines-base-path, '/FedRAMP_rev5_LOW-baseline-resolved-profile_catalog.xml')}"
                  level="fips-199-low"/>
         <profile href="{concat($baselines-base-path, '/FedRAMP_rev5_MODERATE-baseline-resolved-profile_catalog.xml')}"
                  level="fips-199-moderate"/>
         <profile href="{concat($baselines-base-path, '/FedRAMP_rev5_HIGH-baseline-resolved-profile_catalog.xml')}"
                  level="fips-199-high"/>
      </xsl:variable>
      <xsl:variable name="href" select="$profile-map/profile[@level = $level]/@href"/>
      <xsl:sequence select="doc(resolve-uri($href))"/>
   </xsl:function>
   <xsl:function xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
                 xmlns:feddoc="http://us.gov/documentation/federal-documentation"
                 xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="lv:correct">
      <xsl:param as="element()*" name="value-set"/>
      <xsl:param as="node()*" name="value"/>
      <xsl:variable name="values" select="$value-set/f:allowed-values/f:enum/@value"/>
      <xsl:choose>
         <xsl:when test="$value-set/f:allowed-values/@allow-other eq 'no' and $value = $values"/>
         <xsl:otherwise>
            <xsl:value-of select="$values" separator=", "/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
                 xmlns:feddoc="http://us.gov/documentation/federal-documentation"
                 xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="lv:analyze">
      <xsl:param as="element()*" name="value-set"/>
      <xsl:param as="element()*" name="element"/>
      <xsl:choose>
         <xsl:when test="$value-set/f:allowed-values/f:enum/@value">
            <xsl:sequence>
               <xsl:call-template name="analysis-template">
                  <xsl:with-param name="value-set" select="$value-set"/>
                  <xsl:with-param name="element" select="$element"/>
               </xsl:call-template>
            </xsl:sequence>
         </xsl:when>
         <xsl:otherwise>
            <xsl:message expand-text="yes">error</xsl:message>
            <xsl:sequence>
               <xsl:call-template name="analysis-template">
                  <xsl:with-param name="value-set" select="$value-set"/>
                  <xsl:with-param name="element" select="$element"/>
                  <xsl:with-param name="errors">
                     <error>value-set was malformed</error>
                  </xsl:with-param>
               </xsl:call-template>
            </xsl:sequence>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
                 xmlns:feddoc="http://us.gov/documentation/federal-documentation"
                 xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 as="xs:string"
                 name="lv:report">
      <xsl:param as="element()*" name="analysis"/>
      <xsl:variable as="xs:string" name="results">
         <xsl:call-template name="report-template">
            <xsl:with-param name="analysis" select="$analysis"/>
         </xsl:call-template>
      </xsl:variable>
      <xsl:value-of select="$results"/>
   </xsl:function>
   <!--DEFAULT RULES-->
   <!--MODE: SCHEMATRON-SELECT-FULL-PATH-->
   <!--This mode can be used to generate an ugly though full XPath for locators-->
   <xsl:template match="*" mode="schematron-select-full-path">
      <xsl:apply-templates select="." mode="schematron-get-full-path"/>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-->
   <!--This mode can be used to generate an ugly though full XPath for locators-->
   <xsl:template match="*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">
            <xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>*:</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>[namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="preceding"
                    select="count(preceding-sibling::*[local-name()=local-name(current())                                   and namespace-uri() = namespace-uri(current())])"/>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="1+ $preceding"/>
      <xsl:text>]</xsl:text>
   </xsl:template>
   <xsl:template match="@*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">@<xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>@*[local-name()='</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>' and namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-2-->
   <!--This mode can be used to generate prefixed XPath for humans-->
   <xsl:template match="node() | @*" mode="schematron-get-full-path-2">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="preceding-sibling::*[name(.)=name(current())]">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-3-->
   <!--This mode can be used to generate prefixed XPath for humans 
	(Top-level element has index)-->
   <xsl:template match="node() | @*" mode="schematron-get-full-path-3">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="parent::*">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>
   <!--MODE: GENERATE-ID-FROM-PATH -->
   <xsl:template match="/" mode="generate-id-from-path"/>
   <xsl:template match="text()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.text-', 1+count(preceding-sibling::text()), '-')"/>
   </xsl:template>
   <xsl:template match="comment()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.comment-', 1+count(preceding-sibling::comment()), '-')"/>
   </xsl:template>
   <xsl:template match="processing-instruction()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.processing-instruction-', 1+count(preceding-sibling::processing-instruction()), '-')"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.@', name())"/>
   </xsl:template>
   <xsl:template match="*" mode="generate-id-from-path" priority="-0.5">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:text>.</xsl:text>
      <xsl:value-of select="concat('.',name(),'-',1+count(preceding-sibling::*[name()=name(current())]),'-')"/>
   </xsl:template>
   <!--MODE: GENERATE-ID-2 -->
   <xsl:template match="/" mode="generate-id-2">U</xsl:template>
   <xsl:template match="*" mode="generate-id-2" priority="2">
      <xsl:text>U</xsl:text>
      <xsl:number level="multiple" count="*"/>
   </xsl:template>
   <xsl:template match="node()" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>n</xsl:text>
      <xsl:number count="node()"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="string-length(local-name(.))"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="translate(name(),':','.')"/>
   </xsl:template>
   <!--Strip characters-->
   <xsl:template match="text()" priority="-1"/>
   <!--SCHEMA SETUP-->
   <xsl:template match="/">
      <svrl:schematron-output xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                              title="FedRAMP System Security Plan Validations"
                              schemaVersion="">
         <xsl:comment>
            <xsl:value-of select="$archiveDirParameter"/>   
		 <xsl:value-of select="$archiveNameParameter"/>  
		 <xsl:value-of select="$fileNameParameter"/>  
		 <xsl:value-of select="$fileDirParameter"/>
         </xsl:comment>
         <svrl:ns-prefix-in-attribute-values uri="https://fedramp.gov/ns/oscal" prefix="f"/>
         <svrl:ns-prefix-in-attribute-values uri="http://csrc.nist.gov/ns/oscal/1.0" prefix="oscal"/>
         <svrl:ns-prefix-in-attribute-values uri="https://fedramp.gov/ns/oscal" prefix="fedramp"/>
         <svrl:ns-prefix-in-attribute-values uri="local-validations" prefix="lv"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/2005/xpath-functions/array" prefix="array"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/2005/xpath-functions/map" prefix="map"/>
         <svrl:ns-prefix-in-attribute-values uri="http://us.gov/testing/unit-testing" prefix="unit"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">parameters-and-variables</xsl:attribute>
            <xsl:attribute name="name">parameters-and-variables</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M25"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">phase2</xsl:attribute>
            <xsl:attribute name="name">phase2</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M40"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">resources</xsl:attribute>
            <xsl:attribute name="name">Basic resource constraints</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M42"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">base64</xsl:attribute>
            <xsl:attribute name="name">base64 attachments</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M43"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">specific-attachments</xsl:attribute>
            <xsl:attribute name="name">Constraints for specific attachments</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M44"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">policy-and-procedure</xsl:attribute>
            <xsl:attribute name="name">A FedRAMP SSP must incorporate one policy document and one procedure document for each NIST SP 800-53 control family</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M45"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">fips-140</xsl:attribute>
            <xsl:attribute name="name">FIPS 140 Validation</xsl:attribute>
            <xsl:attribute name="see">Guide to OSCAL-based FedRAMP System Security Plans §7.3</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M46"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">fips-199</xsl:attribute>
            <xsl:attribute name="name">Security Objectives Categorization (FIPS 199)</xsl:attribute>
            <xsl:attribute name="see">System Security Plan Template Appendix K</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M47"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">sp800-60</xsl:attribute>
            <xsl:attribute name="name">SP 800-60v2r1 Information Types:</xsl:attribute>
            <xsl:attribute name="see">Guide to OSCAL-based FedRAMP System Security Plans §4.1.6</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M48"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">sp800-63</xsl:attribute>
            <xsl:attribute name="name">Digital Identity Determination</xsl:attribute>
            <xsl:attribute name="see">Guide to OSCAL-based FedRAMP System Security Plans §4.1.5</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M49"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">system-inventory</xsl:attribute>
            <xsl:attribute name="name">FedRAMP SSP inventory items</xsl:attribute>
            <xsl:attribute name="see">Guide to OSCAL-based FedRAMP System Security Plans §5.2</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M50"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">basic-system-characteristics</xsl:attribute>
            <xsl:attribute name="name">basic-system-characteristics</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M51"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">fedramp-data</xsl:attribute>
            <xsl:attribute name="name">fedramp-data</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M52"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">general-roles</xsl:attribute>
            <xsl:attribute name="name">Roles, Locations, Parties, Responsibilities</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M53"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">implementation-roles</xsl:attribute>
            <xsl:attribute name="name">Roles related to implemented requirements</xsl:attribute>
            <xsl:attribute name="see">Guide to OSCAL-based FedRAMP System Security Plans §5.2</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M54"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">user-properties</xsl:attribute>
            <xsl:attribute name="name">user-properties</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M55"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">authorization-boundary</xsl:attribute>
            <xsl:attribute name="name">Authorization Boundary Diagram</xsl:attribute>
            <xsl:attribute name="see">Guide to OSCAL-based FedRAMP System Security Plans §4.8.1</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M56"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">network-architecture</xsl:attribute>
            <xsl:attribute name="name">Network Architecture Diagram</xsl:attribute>
            <xsl:attribute name="see">Guide to OSCAL-based FedRAMP System Security Plans §4.8.2</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M57"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">data-flow</xsl:attribute>
            <xsl:attribute name="name">Data Flow Diagram</xsl:attribute>
            <xsl:attribute name="see">Guide to OSCAL-based FedRAMP System Security Plans §4.8.3</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M58"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">control-implementation</xsl:attribute>
            <xsl:attribute name="name">control-implementation</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M59"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">cloud-models</xsl:attribute>
            <xsl:attribute name="name">Cloud Service and Deployment Models</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M60"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">interconnects</xsl:attribute>
            <xsl:attribute name="name">Interconnections</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M61"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">protocols</xsl:attribute>
            <xsl:attribute name="name">protocols</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M62"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">dns</xsl:attribute>
            <xsl:attribute name="name">dns</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M63"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">info</xsl:attribute>
            <xsl:attribute name="name">info</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M64"/>
      </svrl:schematron-output>
   </xsl:template>
   <!--SCHEMATRON PATTERNS-->
   <doc:xspec xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
              xmlns:feddoc="http://us.gov/documentation/federal-documentation"
              xmlns:sch="http://purl.oclc.org/dsdl/schematron"
              href="../../test/rules/rev5/ssp.xspec"/>
   <xsl:param xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
              xmlns:feddoc="http://us.gov/documentation/federal-documentation"
              xmlns:sch="http://purl.oclc.org/dsdl/schematron"
              as="xs:boolean"
              name="param-use-remote-resources"
              select="false()"/>
   <xsl:param name="use-remote-resources"
              select="$param-use-remote-resources or matches(lower-case(environment-variable('use_remote_resources')), '1|true')"/>
   <xsl:param xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
              xmlns:feddoc="http://us.gov/documentation/federal-documentation"
              xmlns:sch="http://purl.oclc.org/dsdl/schematron"
              as="xs:boolean"
              name="param-use-debug-mode"
              select="false()"/>
   <xsl:param name="use-debug-mode"
              select="$param-use-debug-mode or matches(lower-case(environment-variable('use_debug_mode')), '1|true')"/>
   <!--PATTERN parameters-and-variables-->
   <!--RULE -->
   <xsl:template match="/" priority="1000" mode="M25">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="/"/>
      <!--REPORT information-->
      <xsl:if test="$use-debug-mode eq true()">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="$use-debug-mode eq true()">
            <xsl:attribute name="id">parameter-use-remote-resources</xsl:attribute>
            <xsl:attribute name="role">information</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>parameter use-remote-resources is <xsl:text/>
               <xsl:value-of select="$param-use-remote-resources"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT information-->
      <xsl:if test="$use-debug-mode eq true()">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="$use-debug-mode eq true()">
            <xsl:attribute name="id">environment-variable-use-remote-resources</xsl:attribute>
            <xsl:attribute name="role">information</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>environment-variable use_remote_resources is <xsl:text/>
               <xsl:value-of select="                         if (environment-variable('use_remote_resources') ne '') then                             environment-variable('use_remote_resources')                         else                             'not defined'"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT information-->
      <xsl:if test="$use-debug-mode eq true()">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="$use-debug-mode eq true()">
            <xsl:attribute name="id">variable-use-remote-resources</xsl:attribute>
            <xsl:attribute name="role">information</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>variable use-remote-resources is <xsl:text/>
               <xsl:value-of select="$use-remote-resources"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT information-->
      <xsl:if test="$use-debug-mode eq true()">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="$use-debug-mode eq true()">
            <xsl:attribute name="id">parameter-use-debug-mode</xsl:attribute>
            <xsl:attribute name="role">information</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>parameter use-debug-mode is <xsl:text/>
               <xsl:value-of select="$param-use-debug-mode"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT information-->
      <xsl:if test="$use-debug-mode eq true()">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="$use-debug-mode eq true()">
            <xsl:attribute name="id">environment-variable-use-debug-mode</xsl:attribute>
            <xsl:attribute name="role">information</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>environment-variable use_debug_mode is <xsl:text/>
               <xsl:value-of select="                         if (environment-variable('use_debug_mode') ne '') then                             environment-variable('use_debug_mode')                         else                             'not defined'"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT information-->
      <xsl:if test="$use-debug-mode eq true()">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="$use-debug-mode eq true()">
            <xsl:attribute name="id">variable-use-debug-mode</xsl:attribute>
            <xsl:attribute name="role">information</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>variable use-debug-mode is <xsl:text/>
               <xsl:value-of select="$use-debug-mode"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M25"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M25"/>
   <xsl:template match="@*|node()" priority="-2" mode="M25">
      <xsl:apply-templates select="*" mode="M25"/>
   </xsl:template>
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">FedRAMP System Security Plan Validations</svrl:text>
   <xsl:output xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
               xmlns:feddoc="http://us.gov/documentation/federal-documentation"
               xmlns:sch="http://purl.oclc.org/dsdl/schematron"
               encoding="UTF-8"
               indent="yes"
               method="xml"/>
   <xsl:param xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
              xmlns:feddoc="http://us.gov/documentation/federal-documentation"
              xmlns:sch="http://purl.oclc.org/dsdl/schematron"
              as="xs:string"
              name="registry-base-path"
              select="'../../../content/rev5/resources/xml'"/>
   <xsl:param xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
              xmlns:feddoc="http://us.gov/documentation/federal-documentation"
              xmlns:sch="http://purl.oclc.org/dsdl/schematron"
              as="xs:string"
              name="baselines-base-path"
              select="'../../../../dist/content/rev5/baselines/xml'"/>
   <xsl:param name="registry"
              select="doc(concat($registry-base-path, '/fedramp_values.xml')) | doc(concat($registry-base-path, '/fedramp_threats.xml')) | doc(concat($registry-base-path, '/information-types.xml'))"/>
   <xsl:template xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
                 xmlns:feddoc="http://us.gov/documentation/federal-documentation"
                 xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 as="element()"
                 name="analysis-template">
      <xsl:param as="element()*" name="value-set"/>
      <xsl:param as="element()*" name="element"/>
      <xsl:param as="node()*" name="errors"/>
      <xsl:variable name="ok-values" select="$value-set/f:allowed-values/f:enum/@value"/>
      <analysis>
         <errors>
            <xsl:if test="$errors">
               <xsl:sequence select="$errors"/>
            </xsl:if>
         </errors>
         <reports count="{count($element)}"
                  description="{$value-set/f:description}"
                  formal-name="{$value-set/f:formal-name}"
                  name="{$value-set/@name}">
            <xsl:for-each select="$ok-values">
               <xsl:variable name="match" select="$element[@value = current()]"/>
               <report count="{count($match)}" value="{current()}"/>
            </xsl:for-each>
         </reports>
      </analysis>
   </xsl:template>
   <xsl:template xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
                 xmlns:feddoc="http://us.gov/documentation/federal-documentation"
                 xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 as="xs:string"
                 name="report-template">
      <xsl:param as="element()*" name="analysis"/>
      <xsl:value-of>There are <xsl:value-of select="$analysis/reports/@count"/>  <xsl:value-of select="$analysis/reports/@formal-name"/>
         <xsl:choose>
            <xsl:when test="$analysis/reports/report"> items total, with </xsl:when>
            <xsl:otherwise> items total.</xsl:otherwise>
         </xsl:choose>
         <xsl:for-each select="$analysis/reports/report">
            <xsl:if test="position() gt 0 and not(position() eq last())">
               <xsl:value-of select="current()/@count"/> set as <xsl:value-of select="current()/@value"/>, </xsl:if>
            <xsl:if test="position() gt 0 and position() eq last()"> and <xsl:value-of select="current()/@count"/> set as <xsl:value-of select="current()/@value"/>.</xsl:if>
            <xsl:sequence select="."/>
         </xsl:for-each>There are <xsl:value-of select="($analysis/reports/@count - sum($analysis/reports/report/@count))"/> invalid items. <xsl:if test="count($analysis/errors/error) &gt; 0">
            <xsl:message expand-text="yes">hit error block</xsl:message>
            <xsl:for-each select="$analysis/errors/error">Also, <xsl:value-of select="current()/text()"/>, so analysis could be inaccurate or it completely failed.</xsl:for-each>
         </xsl:if>
      </xsl:value-of>
   </xsl:template>
   <!--PATTERN phase2-->
   <!--RULE -->
   <xsl:template match="/oscal:system-security-plan" priority="1010" mode="M40">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/oscal:system-security-plan"/>
      <xsl:variable name="ok-values"
                    select="$registry/f:fedramp-values/f:value-set[@name eq 'security-level']"/>
      <xsl:variable name="sensitivity-level"
                    select="/ =&gt; lv:sensitivity-level() =&gt; lv:if-empty-default('')"/>
      <xsl:variable name="corrections" select="lv:correct($ok-values, $sensitivity-level)"/>
      <!--ASSERT fatal-->
      <xsl:choose>
         <xsl:when test="count($registry/f:fedramp-values/f:value-set) &gt; 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count($registry/f:fedramp-values/f:value-set) &gt; 0">
               <xsl:attribute name="id">no-registry-values</xsl:attribute>
               <xsl:attribute name="role">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The validation technical components are present.</svrl:text>
               <svrl:diagnostic-reference diagnostic="no-registry-values-diagnostic">
The validation technical components at the path '<xsl:text/>
                  <xsl:value-of select="$registry-base-path"/>
                  <xsl:text/>' are not present, this configuration is invalid.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT fatal-->
      <xsl:choose>
         <xsl:when test="$sensitivity-level ne ''"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$sensitivity-level ne ''">
               <xsl:attribute name="id">no-security-sensitivity-level</xsl:attribute>
               <xsl:attribute name="role">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP must define its sensitivity level.</svrl:text>
               <svrl:diagnostic-reference diagnostic="no-security-sensitivity-level-diagnostic">
No sensitivity level was found. Allowed values are: <xsl:text/>
                  <xsl:value-of select="$corrections"/>
                  <xsl:text/>. As a result, no more validation processing can occur.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT fatal-->
      <xsl:choose>
         <xsl:when test="empty($ok-values) or not(exists($corrections))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="empty($ok-values) or not(exists($corrections))">
               <xsl:attribute name="id">invalid-security-sensitivity-level</xsl:attribute>
               <xsl:attribute name="role">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP must have an allowed sensitivity level.</svrl:text>
               <svrl:diagnostic-reference diagnostic="invalid-security-sensitivity-level-diagnostic">
                  <xsl:text/>
                  <xsl:value-of select="./name()"/>
                  <xsl:text/> is an invalid value of '<xsl:text/>
                  <xsl:value-of select="lv:sensitivity-level(/)"/>
                  <xsl:text/>', not an allowed value of <xsl:text/>
                  <xsl:value-of select="$corrections"/>
                  <xsl:text/>. No more validation processing can occur.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="implemented"
                    select="/oscal:system-security-plan/oscal:control-implementation/oscal:implemented-requirement/oscal:statement"/>
      <!--REPORT information-->
      <xsl:if test="$use-debug-mode eq true()">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="$use-debug-mode eq true()">
            <xsl:attribute name="id">implemented-response-points</xsl:attribute>
            <xsl:attribute name="role">information</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>A FedRAMP SSP must implement a statement for each of the following lettered response points for
                required controls: <xsl:text/>
               <xsl:value-of select="$implemented/@statement-id"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M40"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:system-security-plan/oscal:system-implementation/oscal:component"
                 priority="1009"
                 mode="M40">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:system-security-plan/oscal:system-implementation/oscal:component"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:description/oscal:p/text()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:description/oscal:p/text()">
               <xsl:attribute name="id">no-description-text-in-component</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A component must have a description with content. </svrl:text>
               <svrl:diagnostic-reference diagnostic="no-description-text-in-component-diagnostic">
Component _<xsl:value-of xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
                                xmlns:feddoc="http://us.gov/documentation/federal-documentation"
                                xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                                select="oscal:title"/>_ is missing a description.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M40"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="/oscal:system-security-plan/oscal:control-implementation"
                 priority="1008"
                 mode="M40">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/oscal:system-security-plan/oscal:control-implementation"/>
      <xsl:variable name="registry-ns"
                    select="$registry/f:fedramp-values/f:namespace/f:ns/@ns"/>
      <xsl:variable name="sensitivity-level" select="/ =&gt; lv:sensitivity-level()"/>
      <xsl:variable name="ok-values"
                    select="$registry/f:fedramp-values/f:value-set[@name eq 'control-implementation-status']"/>
      <xsl:variable name="selected-profile" select="$sensitivity-level =&gt; lv:profile()"/>
      <xsl:variable name="required-controls" select="$selected-profile/*//oscal:control"/>
      <xsl:variable name="implemented" select="oscal:implemented-requirement"/>
      <xsl:variable name="all-missing"
                    select="$required-controls[not(@id = $implemented/@control-id)]"/>
      <xsl:variable name="core-missing"
                    select="$required-controls[oscal:prop[@name eq 'CORE' and @ns = $registry-ns] and @id = $all-missing/@id]"/>
      <xsl:variable name="extraneous"
                    select="$implemented[not(@control-id = $required-controls/@id)]"/>
      <!--REPORT information-->
      <xsl:if test="$use-debug-mode eq true()">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="$use-debug-mode eq true()">
            <xsl:attribute name="id">each-required-control-report</xsl:attribute>
            <xsl:attribute name="role">information</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>Sensitivity-level is <xsl:text/>
               <xsl:value-of select="$sensitivity-level"/>
               <xsl:text/>, the following <xsl:text/>
               <xsl:value-of select="count($required-controls)"/>
               <xsl:text/>
               <xsl:text/>
               <xsl:value-of select="                         if (count($required-controls) = 1) then                             ' control'                         else                             ' controls'"/>
               <xsl:text/> are required: <xsl:text/>
               <xsl:value-of select="$required-controls/@id"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="not(exists($all-missing))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(exists($all-missing))">
               <xsl:attribute name="id">incomplete-all-implemented-requirements</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP must implement all required controls.</svrl:text>
               <svrl:diagnostic-reference diagnostic="incomplete-all-implemented-requirements-diagnostic">
A FedRAMP SSP must implement <xsl:text/>
                  <xsl:value-of select="count($all-missing)"/>
                  <xsl:text/>
                  <xsl:text/>
                  <xsl:value-of select="                     if (count($all-missing) = 1) then                         ' control'                     else                         ' controls'"/>
                  <xsl:text/> overall: <xsl:text/>
                  <xsl:value-of select="$all-missing/@id"/>
                  <xsl:text/>.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="not(exists($extraneous))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(exists($extraneous))">
               <xsl:attribute name="id">extraneous-implemented-requirements</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP must not include implemented controls beyond what is required for the applied
                baseline.</svrl:text>
               <svrl:diagnostic-reference diagnostic="extraneous-implemented-requirements-diagnostic">
A FedRAMP SSP must implement <xsl:text/>
                  <xsl:value-of select="count($extraneous)"/>
                  <xsl:text/> extraneous <xsl:text/>
                  <xsl:value-of select="                     if (count($extraneous) = 1) then                         ' control'                     else                         ' controls'"/>
                  <xsl:text/> not needed given the selected profile: <xsl:text/>
                  <xsl:value-of select="$extraneous/@control-id"/>
                  <xsl:text/>.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="results"
                    select="$ok-values =&gt; lv:analyze(//oscal:implemented-requirement/oscal:prop[@name eq 'implementation-status'])"/>
      <xsl:variable name="total" select="$results/reports/@count"/>
      <!--REPORT information-->
      <xsl:if test="count($results/errors/error) = 0 and $use-debug-mode eq true()">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                 test="count($results/errors/error) = 0 and $use-debug-mode eq true()">
            <xsl:attribute name="id">control-implemented-requirements-stats</xsl:attribute>
            <xsl:attribute name="role">information</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
               <xsl:text/>
               <xsl:value-of select="$results =&gt; lv:report() =&gt; normalize-space()"/>
               <xsl:text/>.</svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M40"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="/oscal:system-security-plan/oscal:control-implementation/oscal:implemented-requirement"
                 priority="1007"
                 mode="M40">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/oscal:system-security-plan/oscal:control-implementation/oscal:implemented-requirement"/>
      <xsl:variable name="sensitivity-level"
                    select="/ =&gt; lv:sensitivity-level() =&gt; lv:if-empty-default('')"/>
      <xsl:variable name="selected-profile" select="$sensitivity-level =&gt; lv:profile()"/>
      <xsl:variable name="registry-ns"
                    select="$registry/f:fedramp-values/f:namespace/f:ns/@ns"/>
      <xsl:variable name="status"
                    select="./oscal:prop[@name eq 'implementation-status']/@value"/>
      <xsl:variable name="corrections"
                    select="lv:correct($registry/f:fedramp-values/f:value-set[@name eq 'control-implementation-status'], $status)"/>
      <xsl:variable name="required-response-points"
                    select="$selected-profile/oscal:catalog//oscal:part[@name eq 'item']"/>
      <xsl:variable name="implemented"
                    select="/oscal:system-security-plan/oscal:control-implementation/oscal:implemented-requirement/oscal:statement"/>
      <xsl:variable name="missing"
                    select="$required-response-points[not(@id = $implemented/@statement-id)]"/>
      <xsl:variable name="leveraged"
                    select="//oscal:system-implementation/oscal:leveraged-authorization"/>
      <xsl:variable name="familyName" select="substring-before(@control-id, '-')"/>
      <xsl:variable name="leveragedUUID"
                    select="oscal:prop[@name = 'leveraged-authorization-uuid']/@value"/>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="                     if ($familyName eq 'pe')                     then                         if ($leveraged/@uuid = $leveragedUUID)                         then                             (true())                         else                             (false())                     else                         true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if ($familyName eq 'pe') then if ($leveraged/@uuid = $leveragedUUID) then (true()) else (false()) else true()">
               <xsl:attribute name="id">leveraged-PE-controls-implemented-requirement</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>This PE Control has a leveraged authorization - <xsl:value-of xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
                                xmlns:feddoc="http://us.gov/documentation/federal-documentation"
                                xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                                select="@control-id"/>.</svrl:text>
               <svrl:diagnostic-reference diagnostic="leveraged-PE-controls-implemented-requirement-diagnostic">
This PE Control does not have a matching leveraged authorization - <xsl:value-of xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
                                xmlns:feddoc="http://us.gov/documentation/federal-documentation"
                                xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                                select="@control-id"/>.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT information-->
      <xsl:choose>
         <xsl:when test="not(exists($corrections))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(exists($corrections))">
               <xsl:attribute name="id">invalid-implementation-status</xsl:attribute>
               <xsl:attribute name="role">information</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Implementation status is correct.</svrl:text>
               <svrl:diagnostic-reference diagnostic="invalid-implementation-status-diagnostic">
Invalid implementation status '<xsl:text/>
                  <xsl:value-of select="$status"/>
                  <xsl:text/>' for <xsl:text/>
                  <xsl:value-of select="./@control-id"/>
                  <xsl:text/>, must be <xsl:text/>
                  <xsl:value-of select="$corrections"/>
                  <xsl:text/>.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="                     if (matches(@control-id, 'sc-20|sc-21'))                     then                         (if (self::oscal:implemented-requirement//*[matches(., 'DNSSEC|DNS Security Extensions')])                         then                             (true())                         else                             (false()))                     else                         (true())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (matches(@control-id, 'sc-20|sc-21')) then (if (self::oscal:implemented-requirement//*[matches(., 'DNSSEC|DNS Security Extensions')]) then (true()) else (false())) else (true())">
               <xsl:attribute name="id">DNSSEC-described</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Implemented Requirement <xsl:value-of xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
                                xmlns:feddoc="http://us.gov/documentation/federal-documentation"
                                xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                                select="@control-id"/> exists.</svrl:text>
               <svrl:diagnostic-reference diagnostic="DNSSEC-described-diagnostic">
The implemented requirement does not contain the strings 'DNSSEC' or 'DNS Security
            Extensions'.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="                     if (matches(@control-id, 'cm-9'))                     then                         (if (self::oscal:implemented-requirement//*[matches(., 'CIS|Center for Internet Security|SCAP')])                         then                             (true())                         else                             (false()))                     else                         (true())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (matches(@control-id, 'cm-9')) then (if (self::oscal:implemented-requirement//*[matches(., 'CIS|Center for Internet Security|SCAP')]) then (true()) else (false())) else (true())">
               <xsl:attribute name="id">configuration-management-controls-described</xsl:attribute>
               <xsl:attribute name="see">https://github.com/18F/fedramp-automation/issues/313</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Implemented Requirement <xsl:value-of xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
                                xmlns:feddoc="http://us.gov/documentation/federal-documentation"
                                xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                                select="@control-id"/> exists and has acceptable keywords.</svrl:text>
               <svrl:diagnostic-reference diagnostic="configuration-management-controls-described-diagnostic">
The implemented requirement <xsl:text/>
                  <xsl:value-of select="@control-id"/>
                  <xsl:text/> does not contain the strings 'CIS' or 'Center for Internet Security' or 'SCAP'.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M40"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="/oscal:system-security-plan/oscal:control-implementation/oscal:implemented-requirement/oscal:statement"
                 priority="1006"
                 mode="M40">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/oscal:system-security-plan/oscal:control-implementation/oscal:implemented-requirement/oscal:statement"/>
      <xsl:variable name="required-components-count" select="1"/>
      <xsl:variable name="required-length" select="20"/>
      <xsl:variable name="components-count" select="./oscal:by-component =&gt; count()"/>
      <xsl:variable name="remarks" select="./oscal:remarks =&gt; normalize-space()"/>
      <xsl:variable name="remarks-length" select="$remarks =&gt; string-length()"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="exists(oscal:by-component)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(oscal:by-component)">
               <xsl:attribute name="id">missing-response-components</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Response statements have one or more components.</svrl:text>
               <svrl:diagnostic-reference diagnostic="missing-response-components-diagnostic">
Response statements for <xsl:text/>
                  <xsl:value-of select="./@statement-id"/>
                  <xsl:text/> must have at least <xsl:text/>
                  <xsl:value-of select="$required-components-count"/>
                  <xsl:text/>
                  <xsl:text/>
                  <xsl:value-of select="                     if (count($components-count) = 1) then                         ' component'                     else                         ' components'"/>
                  <xsl:text/> with a description. There are <xsl:text/>
                  <xsl:value-of select="$components-count"/>
                  <xsl:text/>.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not(exists(oscal:description))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(exists(oscal:description))">
               <xsl:attribute name="id">extraneous-response-description</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Response statement has a description not within a component.</svrl:text>
               <svrl:diagnostic-reference diagnostic="extraneous-response-description-diagnostic">
Response statement <xsl:text/>
                  <xsl:value-of select="../@statement-id"/>
                  <xsl:text/> may not have a description not within a component. This is invalid.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not(exists(oscal:remarks))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(exists(oscal:remarks))">
               <xsl:attribute name="id">extraneous-response-remarks</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Response statement does not have remarks not within a component.</svrl:text>
               <svrl:diagnostic-reference diagnostic="extraneous-response-remarks-diagnostic">
Response statement <xsl:text/>
                  <xsl:value-of select="../@statement-id"/>
                  <xsl:text/> has remarks not within a component. That was previously allowed, but not recommended. It will soon be
            syntactically invalid and deprecated.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M40"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="/oscal:system-security-plan/oscal:control-implementation/oscal:implemented-requirement/oscal:statement/oscal:by-component"
                 priority="1005"
                 mode="M40">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/oscal:system-security-plan/oscal:control-implementation/oscal:implemented-requirement/oscal:statement/oscal:by-component"/>
      <xsl:variable name="component-ref" select="./@component-uuid"/>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="/oscal:system-security-plan/oscal:system-implementation/oscal:component[@uuid eq $component-ref] =&gt; exists()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="/oscal:system-security-plan/oscal:system-implementation/oscal:component[@uuid eq $component-ref] =&gt; exists()">
               <xsl:attribute name="id">invalid-component-match</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Response statement
                cites a component in the system implementation inventory.</svrl:text>
               <svrl:diagnostic-reference diagnostic="invalid-component-match-diagnostic">
Response statement <xsl:text/>
                  <xsl:value-of select="../@statement-id"/>
                  <xsl:text/> with component reference UUID ' <xsl:text/>
                  <xsl:value-of select="$component-ref"/>
                  <xsl:text/>' is not in the system implementation inventory, and cannot be used to define a control.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="./oscal:description =&gt; exists()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="./oscal:description =&gt; exists()">
               <xsl:attribute name="id">missing-component-description</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Response statement has a component which has a required description.</svrl:text>
               <svrl:diagnostic-reference diagnostic="missing-component-description-diagnostic">
Response statement <xsl:text/>
                  <xsl:value-of select="../@statement-id"/>
                  <xsl:text/> has a component, but that component is missing a required description node.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M40"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="/oscal:system-security-plan/oscal:control-implementation/oscal:implemented-requirement/oscal:statement/oscal:by-component/oscal:description"
                 priority="1004"
                 mode="M40">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/oscal:system-security-plan/oscal:control-implementation/oscal:implemented-requirement/oscal:statement/oscal:by-component/oscal:description"/>
      <xsl:variable name="required-length" select="20"/>
      <xsl:variable name="description" select=". =&gt; normalize-space()"/>
      <xsl:variable name="description-length" select="$description =&gt; string-length()"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="$description-length ge $required-length"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="$description-length ge $required-length">
               <xsl:attribute name="id">incomplete-response-description</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Response statement component description has adequate length.</svrl:text>
               <svrl:diagnostic-reference diagnostic="incomplete-response-description-diagnostic">
Response statement component description for <xsl:text/>
                  <xsl:value-of select="../../@statement-id"/>
                  <xsl:text/> is too short with <xsl:text/>
                  <xsl:value-of select="$description-length"/>
                  <xsl:text/> characters. It must be <xsl:text/>
                  <xsl:value-of select="$required-length"/>
                  <xsl:text/> characters long.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M40"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="/oscal:system-security-plan/oscal:control-implementation/oscal:implemented-requirement/oscal:statement/oscal:by-component/oscal:remarks"
                 priority="1003"
                 mode="M40">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/oscal:system-security-plan/oscal:control-implementation/oscal:implemented-requirement/oscal:statement/oscal:by-component/oscal:remarks"/>
      <xsl:variable name="required-length" select="20"/>
      <xsl:variable name="remarks" select=". =&gt; normalize-space()"/>
      <xsl:variable name="remarks-length" select="$remarks =&gt; string-length()"/>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="$remarks-length ge $required-length"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="$remarks-length ge $required-length">
               <xsl:attribute name="id">incomplete-response-remarks</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Response statement component remarks have adequate length.</svrl:text>
               <svrl:diagnostic-reference diagnostic="incomplete-response-remarks-diagnostic">
Response statement component remarks for <xsl:text/>
                  <xsl:value-of select="../../@statement-id"/>
                  <xsl:text/> is too short with <xsl:text/>
                  <xsl:value-of select="$remarks-length"/>
                  <xsl:text/> characters. It must be <xsl:text/>
                  <xsl:value-of select="$required-length"/>
                  <xsl:text/> characters long.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M40"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="/oscal:system-security-plan/oscal:metadata"
                 priority="1002"
                 mode="M40">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/oscal:system-security-plan/oscal:metadata"/>
      <xsl:variable name="parties" select="oscal:party"/>
      <xsl:variable name="roles" select="oscal:role"/>
      <xsl:variable name="responsible-parties" select="./oscal:responsible-party"/>
      <xsl:variable name="extraneous-roles"
                    select="$responsible-parties[not(@role-id = $roles/@id)]"/>
      <xsl:variable name="extraneous-parties"
                    select="$responsible-parties[not(oscal:party-uuid = $parties/@uuid)]"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not(exists($extraneous-roles))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(exists($extraneous-roles))">
               <xsl:attribute name="id">incorrect-role-association</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP must define a responsible party with no extraneous roles.</svrl:text>
               <svrl:diagnostic-reference diagnostic="incorrect-role-association-diagnostic">
A FedRAMP SSP must define a responsible party with <xsl:text/>
                  <xsl:value-of select="count($extraneous-roles)"/>
                  <xsl:text/>
                  <xsl:text/>
                  <xsl:value-of select="                     if (count($extraneous-roles) = 1) then                         ' role'                     else                         ' roles'"/>
                  <xsl:text/> not defined in the role: <xsl:text/>
                  <xsl:value-of select="$extraneous-roles/@role-id"/>
                  <xsl:text/>.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not(exists($extraneous-parties))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(exists($extraneous-parties))">
               <xsl:attribute name="id">incorrect-party-association</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP must define a responsible party with no extraneous parties.</svrl:text>
               <svrl:diagnostic-reference diagnostic="incorrect-party-association-diagnostic">
A FedRAMP SSP must define a responsible party with <xsl:text/>
                  <xsl:value-of select="count($extraneous-parties)"/>
                  <xsl:text/>
                  <xsl:text/>
                  <xsl:value-of select="                     if (count($extraneous-parties) = 1) then                         ' party'                     else                         ' parties'"/>
                  <xsl:text/> is not a defined party: <xsl:text/>
                  <xsl:value-of select="$extraneous-parties/oscal:party-uuid"/>
                  <xsl:text/>.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M40"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="/oscal:system-security-plan/oscal:back-matter/oscal:resource"
                 priority="1001"
                 mode="M40">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/oscal:system-security-plan/oscal:back-matter/oscal:resource"/>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="@uuid"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@uuid">
               <xsl:attribute name="id">resource-uuid-required</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Every supporting artifact found in a citation has a unique identifier.</svrl:text>
               <svrl:diagnostic-reference diagnostic="resource-uuid-required-diagnostic">
This FedRAMP SSP has a back-matter resource which lacks a UUID.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M40"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="/oscal:system-security-plan/oscal:back-matter/oscal:resource/oscal:base64"
                 priority="1000"
                 mode="M40">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/oscal:system-security-plan/oscal:back-matter/oscal:resource/oscal:base64"/>
      <xsl:variable name="filename" select="@filename"/>
      <xsl:variable name="media-type" select="@media-type"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="./@filename"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="./@filename">
               <xsl:attribute name="id">resource-base64-available-filename</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Every declared embedded attachment has a filename attribute.</svrl:text>
               <svrl:diagnostic-reference diagnostic="resource-base64-available-filename-diagnostic">
This base64 lacks a filename attribute.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="./@media-type"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="./@media-type">
               <xsl:attribute name="id">resource-base64-available-media-type</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Every declared embedded attachment has a media type.</svrl:text>
               <svrl:diagnostic-reference diagnostic="resource-base64-available-media-type-diagnostic">
This base64 lacks a media-type attribute.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M40"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M40"/>
   <xsl:template match="@*|node()" priority="-2" mode="M40">
      <xsl:apply-templates select="*" mode="M40"/>
   </xsl:template>
   <xsl:param name="fedramp-values"
              select="doc(concat($registry-base-path, '/fedramp_values.xml'))"/>
   <!--PATTERN resourcesBasic resource constraints-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Basic resource constraints</svrl:text>
   <xsl:variable name="attachment-types"
                 select="$fedramp-values//fedramp:value-set[@name eq 'attachment-type']//fedramp:enum/@value"/>
   <!--RULE -->
   <xsl:template match="oscal:resource" priority="1003" mode="M42">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="oscal:resource"/>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="@uuid"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@uuid">
               <xsl:attribute name="id">resource-has-uuid</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Every supporting artifact found in a citation must have a unique identifier.</svrl:text>
               <svrl:diagnostic-reference diagnostic="resource-has-uuid-diagnostic">
This resource lacks a uuid attribute.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="oscal:title"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="oscal:title">
               <xsl:attribute name="id">resource-has-title</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Every supporting artifact found in a citation should have a title.</svrl:text>
               <svrl:diagnostic-reference diagnostic="resource-has-title-diagnostic">
This resource lacks a title.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="oscal:rlink"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="oscal:rlink">
               <xsl:attribute name="id">resource-has-rlink</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Every supporting artifact found in a citation must have a rlink element.</svrl:text>
               <svrl:diagnostic-reference diagnostic="resource-has-rlink-diagnostic">
This resource lacks a rlink element.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT information-->
      <xsl:choose>
         <xsl:when test="@uuid = (//@href[matches(., '^#')] ! substring-after(., '#'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@uuid = (//@href[matches(., '^#')] ! substring-after(., '#'))">
               <xsl:attribute name="id">resource-is-referenced</xsl:attribute>
               <xsl:attribute name="role">information</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Every supporting artifact found in a citation should be
                referenced from within the document.</svrl:text>
               <svrl:diagnostic-reference diagnostic="resource-is-referenced-diagnostic">
This resource lacks a reference within the document.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M42"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:back-matter/oscal:resource/oscal:prop[@name eq 'type']"
                 priority="1002"
                 mode="M42">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:back-matter/oscal:resource/oscal:prop[@name eq 'type']"/>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="@value = $attachment-types"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@value = $attachment-types">
               <xsl:attribute name="id">attachment-type-is-valid</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A supporting artifact found in a citation should have an allowed attachment type.</svrl:text>
               <svrl:diagnostic-reference diagnostic="attachment-type-is-valid-diagnostic">
Found unknown attachment type «<xsl:text/>
                  <xsl:value-of select="@value"/>
                  <xsl:text/>» in <xsl:text/>
                  <xsl:value-of select="                     if (parent::oscal:resource/oscal:title) then                         concat('&#34;', parent::oscal:resource/oscal:title, '&#34;')                     else                         'untitled'"/>
                  <xsl:text/> resource.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M42"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:back-matter/oscal:resource/oscal:rlink"
                 priority="1001"
                 mode="M42">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:back-matter/oscal:resource/oscal:rlink"/>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="@href"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@href">
               <xsl:attribute name="id">rlink-has-href</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Every supporting artifact found in a citation rlink must have a reference.</svrl:text>
               <svrl:diagnostic-reference diagnostic="rlink-has-href-diagnostic">
This rlink lacks an href attribute.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="not($use-remote-resources) or unparsed-text-available(@href)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not($use-remote-resources) or unparsed-text-available(@href)">
               <xsl:attribute name="id">rlink-href-is-available</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Every supporting artifact found in a citation rlink must have a reachable reference.</svrl:text>
               <svrl:diagnostic-reference diagnostic="rlink-href-is-available-diagnostic">
This supporting artifact found in a citation rlink has an unreachable reference.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M42"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:rlink | oscal:base64" priority="1000" mode="M42">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:rlink | oscal:base64"
                       role="error"/>
      <xsl:variable name="media-types"
                    select="$fedramp-values//fedramp:value-set[@name eq 'media-type']//fedramp:enum/@value"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@media-type = $media-types"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@media-type = $media-types">
               <xsl:attribute name="id">has-allowed-media-type</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A media-type attribute must have an allowed value.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-allowed-media-type-diagnostic">
This <xsl:text/>
                  <xsl:value-of select="name(parent::node())"/>
                  <xsl:text/> has a media-type="<xsl:text/>
                  <xsl:value-of select="current()/@media-type"/>
                  <xsl:text/>" which is not in the list of allowed media types. Allowed media types are <xsl:text/>
                  <xsl:value-of select="string-join($media-types, ' ∨ ')"/>
                  <xsl:text/>.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M42"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M42"/>
   <xsl:template match="@*|node()" priority="-2" mode="M42">
      <xsl:apply-templates select="*" mode="M42"/>
   </xsl:template>
   <!--PATTERN base64base64 attachments-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">base64 attachments</svrl:text>
   <!--RULE -->
   <xsl:template match="oscal:back-matter/oscal:resource" priority="1001" mode="M43">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:back-matter/oscal:resource"/>
      <!--ASSERT information-->
      <xsl:choose>
         <xsl:when test="oscal:base64"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="oscal:base64">
               <xsl:attribute name="id">resource-has-base64</xsl:attribute>
               <xsl:attribute name="role">information</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A supporting artifact found in a citation should have an embedded attachment element.</svrl:text>
               <svrl:diagnostic-reference diagnostic="resource-has-base64-diagnostic">
This resource lacks a base64 element.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="not(oscal:base64[2])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(oscal:base64[2])">
               <xsl:attribute name="id">resource-has-base64-cardinality</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A supporting artifact found in a citation must have only one embedded attachment element.</svrl:text>
               <svrl:diagnostic-reference diagnostic="resource-base64-cardinality-diagnostic">
This resource must not have more than one base64 element.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M43"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:back-matter/oscal:resource/oscal:base64"
                 priority="1000"
                 mode="M43">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:back-matter/oscal:resource/oscal:base64"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@filename"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@filename">
               <xsl:attribute name="id">base64-has-filename</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Every embedded attachment element must have a filename attribute.</svrl:text>
               <svrl:diagnostic-reference diagnostic="base64-has-filename-diagnostic">
This base64 must have a filename attribute.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@media-type"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@media-type">
               <xsl:attribute name="id">base64-has-media-type</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Every embedded attachment element must have a media type.</svrl:text>
               <svrl:diagnostic-reference diagnostic="base64-has-media-type-diagnostic">
This base64 element lacks a media-type attribute.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="matches(normalize-space(), '^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/][AQgw]==|[A-Za-z0-9+/]{2}[AEIMQUYcgkosw048]=)?$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(normalize-space(), '^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/][AQgw]==|[A-Za-z0-9+/]{2}[AEIMQUYcgkosw048]=)?$')">
               <xsl:attribute name="id">base64-has-content</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> Every
                embedded attachment element must have content.</svrl:text>
               <svrl:diagnostic-reference diagnostic="base64-has-content-diagnostic">
This base64 element lacks content.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M43"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M43"/>
   <xsl:template match="@*|node()" priority="-2" mode="M43">
      <xsl:apply-templates select="*" mode="M43"/>
   </xsl:template>
   <!--PATTERN specific-attachmentsConstraints for specific attachments-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Constraints for specific attachments</svrl:text>
   <!--RULE -->
   <xsl:template match="oscal:back-matter" priority="1000" mode="M44">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="oscal:back-matter">
         <xsl:attribute name="see">https://github.com/18F/fedramp-automation/blob/master/documents/Guide_to_OSCAL-based_FedRAMP_System_Security_Plans_(SSP).pdf</xsl:attribute>
      </svrl:fired-rule>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="oscal:resource[oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'type' and @value eq 'fedramp-logo']]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:resource[oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'type' and @value eq 'fedramp-logo']]">
               <xsl:attribute name="id">has-fedramp-logo</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP
                SSP must have the FedRAMP Logo attached.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-fedramp-logo-diagnostic">
This FedRAMP SSP lacks the FedRAMP Logo.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="oscal:resource[oscal:prop[@name eq 'type' and @value eq 'users-guide']]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:resource[oscal:prop[@name eq 'type' and @value eq 'users-guide']]">
               <xsl:attribute name="id">has-user-guide</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP must have a User Guide attached.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-user-guide-diagnostic">
This FedRAMP SSP lacks a User Guide.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="oscal:resource[oscal:prop[@name eq 'type' and @value eq 'rules-of-behavior']]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:resource[oscal:prop[@name eq 'type' and @value eq 'rules-of-behavior']]">
               <xsl:attribute name="id">has-rules-of-behavior</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP must have Rules of Behavior.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-rules-of-behavior-diagnostic">
This FedRAMP SSP lacks a Rules of Behavior.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="oscal:resource[oscal:prop[@name eq 'type' and @value eq 'plan' and @class eq 'information-system-contingency-plan']]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:resource[oscal:prop[@name eq 'type' and @value eq 'plan' and @class eq 'information-system-contingency-plan']]">
               <xsl:attribute name="id">has-information-system-contingency-plan</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                A FedRAMP SSP must have a Contingency Plan attached.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-information-system-contingency-plan-diagnostic">
This FedRAMP SSP lacks a Contingency Plan.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="oscal:resource[oscal:prop[@name eq 'type' and @value eq 'plan' and @class eq 'configuration-management-plan']]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:resource[oscal:prop[@name eq 'type' and @value eq 'plan' and @class eq 'configuration-management-plan']]">
               <xsl:attribute name="id">has-configuration-management-plan</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                A FedRAMP SSP must have a Configuration Management Plan attached.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-configuration-management-plan-diagnostic">
This FedRAMP SSP lacks a Configuration Management Plan.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="oscal:resource[oscal:prop[@name eq 'type' and @value eq 'plan' and @class eq 'incident-response-plan']]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:resource[oscal:prop[@name eq 'type' and @value eq 'plan' and @class eq 'incident-response-plan']]">
               <xsl:attribute name="id">has-incident-response-plan</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP must have 
                an Incident Response Plan attached.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-incident-response-plan-diagnostic">
This FedRAMP SSP lacks an Incident Response Plan.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="oscal:resource[oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'type' and @value eq 'separation-of-duties-matrix']]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:resource[oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'type' and @value eq 'separation-of-duties-matrix']]">
               <xsl:attribute name="id">has-separation-of-duties-matrix</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                A FedRAMP SSP must have a Separation of Duties Matrix attached.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-separation-of-duties-matrix-diagnostic">
This FedRAMP SSP lacks a Separation of Duties Matrix.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M44"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M44"/>
   <xsl:template match="@*|node()" priority="-2" mode="M44">
      <xsl:apply-templates select="*" mode="M44"/>
   </xsl:template>
   <!--PATTERN policy-and-procedurePolicy and Procedure attachments A FedRAMP SSP must incorporate one policy document and one procedure document for each NIST SP 800-53 control family-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Policy and Procedure attachments</svrl:text>
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">A FedRAMP SSP must incorporate one policy document and one procedure document for each NIST SP 800-53 control family</svrl:text>
   <!--RULE -->
   <xsl:template match="oscal:implemented-requirement[matches(@control-id, '^[a-z]{2}-1$')]"
                 priority="1001"
                 mode="M45">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:implemented-requirement[matches(@control-id, '^[a-z]{2}-1$')]">
         <xsl:attribute name="see">Guide to OSCAL-based FedRAMP System Security Plans §5</xsl:attribute>
      </svrl:fired-rule>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="                     (: legacy approach :)                     (descendant::oscal:by-component/oscal:link[@rel eq 'policy'])                     or                     (: component approach :)                     (some $c in                     //oscal:component[@uuid = current()/descendant::oscal:by-component/@component-uuid]                         satisfies $c/@type = 'policy' and $c/oscal:link[@rel eq 'policy'])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="(: legacy approach :) (descendant::oscal:by-component/oscal:link[@rel eq 'policy']) or (: component approach :) (some $c in //oscal:component[@uuid = current()/descendant::oscal:by-component/@component-uuid] satisfies $c/@type = 'policy' and $c/oscal:link[@rel eq 'policy'])">
               <xsl:attribute name="id">has-policy-link</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP must incorporate a policy
                document for each NIST SP 800-53 control family.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-policy-link-diagnostic">
implemented-requirement <xsl:text/>
                  <xsl:value-of select="@control-id"/>
                  <xsl:text/> lacks policy reference(s) via legacy or component approach.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="policy-hrefs"
                    select="distinct-values((descendant::oscal:by-component/oscal:link[@rel eq 'policy']/@href, //oscal:component[@type = 'policy' and @uuid = current()/descendant::oscal:by-component/@component-uuid]/oscal:link/@href) ! substring-after(., '#'))"/>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="                     every $ref in $policy-hrefs                         satisfies exists(//oscal:resource[oscal:prop[@name eq 'type' and @value eq 'policy']][@uuid eq $ref])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $ref in $policy-hrefs satisfies exists(//oscal:resource[oscal:prop[@name eq 'type' and @value eq 'policy']][@uuid eq $ref])">
               <xsl:attribute name="id">has-policy-attachment-resource</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A
                FedRAMP SSP must incorporate a policy document for each NIST SP 800-53 control family.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-policy-attachment-resource-diagnostic">
implemented-requirement <xsl:text/>
                  <xsl:value-of select="@control-id"/>
                  <xsl:text/> lacks policy attachment resource(s) <xsl:text/>
                  <xsl:value-of select="string-join($policy-hrefs, ', ')"/>
                  <xsl:text/>.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="                     (: legacy approach :)                     (descendant::oscal:by-component/oscal:link[@rel eq 'procedure'])                     or                     (: component approach :)                     (some $c in                     //oscal:component[@uuid = current()/descendant::oscal:by-component/@component-uuid]                         satisfies $c/@type = 'procedure' and $c/oscal:link[@rel eq 'procedure'])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="(: legacy approach :) (descendant::oscal:by-component/oscal:link[@rel eq 'procedure']) or (: component approach :) (some $c in //oscal:component[@uuid = current()/descendant::oscal:by-component/@component-uuid] satisfies $c/@type = 'procedure' and $c/oscal:link[@rel eq 'procedure'])">
               <xsl:attribute name="id">has-procedure-link</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP must incorporate a
                procedure document for each NIST SP 800-53 control family.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-procedure-link-diagnostic">
implemented-requirement <xsl:text/>
                  <xsl:value-of select="@control-id"/>
                  <xsl:text/> lacks procedure reference(s) via legacy or component approach.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="procedure-hrefs"
                    select="distinct-values((descendant::oscal:by-component/oscal:link[@rel eq 'procedure']/@href, //oscal:component[@type = 'procedure' and @uuid = current()/descendant::oscal:by-component/@component-uuid]/oscal:link/@href) ! substring-after(., '#'))"/>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="                     (: targets of links exist in the document :)                     every $ref in $procedure-hrefs                         satisfies exists(//oscal:resource[oscal:prop[@name eq 'type' and @value eq 'procedure']][@uuid eq $ref])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="(: targets of links exist in the document :) every $ref in $procedure-hrefs satisfies exists(//oscal:resource[oscal:prop[@name eq 'type' and @value eq 'procedure']][@uuid eq $ref])">
               <xsl:attribute name="id">has-procedure-attachment-resource</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A
                FedRAMP SSP must incorporate a procedure document for each NIST SP 800-53 control family.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-procedure-attachment-resource-diagnostic">
implemented-requirement <xsl:text/>
                  <xsl:value-of select="@control-id"/>
                  <xsl:text/> lacks procedure attachment resource(s) <xsl:text/>
                  <xsl:value-of select="string-join($procedure-hrefs, ', ')"/>
                  <xsl:text/>.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M45"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:by-component/oscal:link[@rel = ('policy', 'procedure')]"
                 priority="1000"
                 mode="M45">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:by-component/oscal:link[@rel = ('policy', 'procedure')]"/>
      <xsl:variable name="ir" select="ancestor::oscal:implemented-requirement"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     not(                     (: the current @href is not in :)                     @href =                     (: all controls except the current :) (//oscal:implemented-requirement[matches(@control-id, '^[a-z]{2}-1$')] except $ir)                     (: all their @hrefs :)/descendant::oscal:by-component/oscal:link[@rel eq 'policy']/@href                     )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not( (: the current @href is not in :) @href = (: all controls except the current :) (//oscal:implemented-requirement[matches(@control-id, '^[a-z]{2}-1$')] except $ir) (: all their @hrefs :)/descendant::oscal:by-component/oscal:link[@rel eq 'policy']/@href )">
               <xsl:attribute name="id">has-unique-policy-and-procedure</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Policy and procedure documents must have unique per-control-family associations.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-unique-policy-and-procedure-diagnostic">
A policy or procedure reference was incorrectly re-used.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M45"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M45"/>
   <xsl:template match="@*|node()" priority="-2" mode="M45">
      <xsl:apply-templates select="*" mode="M45"/>
   </xsl:template>
   <!--PATTERN fips-140FIPS 140 Validation-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">FIPS 140 Validation</svrl:text>
   <!--RULE -->
   <xsl:template match="oscal:system-implementation" priority="1003" mode="M46">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:system-implementation"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:component[@type eq 'validation']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:component[@type eq 'validation']">
               <xsl:attribute name="id">has-CMVP-validation</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP must incorporate one or more FIPS 140 validated modules.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-CMVP-validation-diagnostic">
This FedRAMP SSP does not declare one or more FIPS 140 validated modules.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M46"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:component[@type eq 'validation']"
                 priority="1002"
                 mode="M46">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:component[@type eq 'validation']"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:prop[@name eq 'validation-reference']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:prop[@name eq 'validation-reference']">
               <xsl:attribute name="id">has-CMVP-validation-reference</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Every FIPS 140 validation citation must have a validation reference.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-CMVP-validation-reference-diagnostic">
This validation component or inventory-item lacks a validation-reference
            property.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:link[@rel eq 'validation-details']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:link[@rel eq 'validation-details']">
               <xsl:attribute name="id">has-CMVP-validation-details</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Every FIPS 140 validation citation must have validation details.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-CMVP-validation-details-diagnostic">
This validation component or inventory-item lacks a validation-details link.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M46"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:prop[@name eq 'validation-reference']"
                 priority="1001"
                 mode="M46">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:prop[@name eq 'validation-reference']"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="matches(@value, '^\d{3,4}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(@value, '^\d{3,4}$')">
               <xsl:attribute name="id">has-credible-CMVP-validation-reference</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A validation reference must provide a NIST Cryptographic Module Validation Program (CMVP)
                certificate number.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-credible-CMVP-validation-reference-diagnostic">
This validation-reference property does not resemble a CMVP certificate
            number.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@value = tokenize(following-sibling::oscal:link[@rel eq 'validation-details']/@href, '/')[last()]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@value = tokenize(following-sibling::oscal:link[@rel eq 'validation-details']/@href, '/')[last()]">
               <xsl:attribute name="id">has-consonant-CMVP-validation-reference</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A validation reference must
                be in accord with its sibling validation details.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-consonant-CMVP-validation-reference-diagnostic">
This validation-reference property does not match its sibling validation-details
            href.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M46"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:link[@rel eq 'validation-details']"
                 priority="1000"
                 mode="M46">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:link[@rel eq 'validation-details']"/>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="matches(@href, '^https://csrc\.nist\.gov/projects/cryptographic-module-validation-program/[Cc]ertificate/\d{3,4}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(@href, '^https://csrc\.nist\.gov/projects/cryptographic-module-validation-program/[Cc]ertificate/\d{3,4}$')">
               <xsl:attribute name="id">has-credible-CMVP-validation-details</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                Validation details must refer to a NIST Cryptographic Module Validation Program (CMVP) certificate detail page.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-credible-CMVP-validation-details-diagnostic">
This validation-details link href attribute does not resemble a CMVP certificate
            URL.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not($use-remote-resources) or unparsed-text-available(@href)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not($use-remote-resources) or unparsed-text-available(@href)">
               <xsl:attribute name="id">has-accessible-CMVP-validation-details</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The NIST Cryptographic Module Validation Program (CMVP) certificate detail page is available.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-accessible-CMVP-validation-details-diagnostic">
This validation-details link references an inaccessible NIST CMVP
            certificate.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="tokenize(@href, '/')[last()] = preceding-sibling::oscal:prop[@name eq 'validation-reference']/@value"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="tokenize(@href, '/')[last()] = preceding-sibling::oscal:prop[@name eq 'validation-reference']/@value">
               <xsl:attribute name="id">has-consonant-CMVP-validation-details</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A validation details link
                must be in accord with its sibling validation reference.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-consonant-CMVP-validation-details-diagnostic">
This validation-details link href attribute does not match its sibling
            validation-reference value.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M46"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M46"/>
   <xsl:template match="@*|node()" priority="-2" mode="M46">
      <xsl:apply-templates select="*" mode="M46"/>
   </xsl:template>
   <!--PATTERN fips-199Security Objectives Categorization (FIPS 199)-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Security Objectives Categorization (FIPS 199)</svrl:text>
   <!--RULE -->
   <xsl:template match="oscal:system-characteristics" priority="1003" mode="M47">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:system-characteristics"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:security-sensitivity-level"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:security-sensitivity-level">
               <xsl:attribute name="id">has-security-sensitivity-level</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An OSCAL SSP document must specify a FIPS 199 categorization.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-security-sensitivity-level-diagnostic">
This OSCAL SSP document lacks a FIPS 199 categorization.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:security-impact-level"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:security-impact-level">
               <xsl:attribute name="id">has-security-impact-level</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An OSCAL SSP document must specify a security impact level.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-security-impact-level-diagnostic">
This OSCAL SSP document lacks a security impact level.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M47"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:security-sensitivity-level" priority="1002" mode="M47">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:security-sensitivity-level"/>
      <xsl:variable name="security-sensitivity-levels"
                    select="$fedramp-values//fedramp:value-set[@name eq 'security-level']//fedramp:enum/@value"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="current() = $security-sensitivity-levels"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="current() = $security-sensitivity-levels">
               <xsl:attribute name="id">has-allowed-security-sensitivity-level</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP must specify an allowed security sensitivity level.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-allowed-security-sensitivity-level-diagnostic">
Invalid security-sensitivity-level "<xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>". It must have one of the following <xsl:text/>
                  <xsl:value-of select="count($security-sensitivity-levels)"/>
                  <xsl:text/> values: <xsl:text/>
                  <xsl:value-of select="string-join($security-sensitivity-levels, ' ∨ ')"/>
                  <xsl:text/>.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="security-level-string"
                    select="string-join(../oscal:security-impact-level//text())"/>
      <xsl:variable name="security-impact-level"
                    select="                     if (matches($security-level-string, 'high'))                     then                         ('fips-199-high')                     else                         (if (matches($security-level-string, 'moderate'))                         then                             ('fips-199-moderate')                         else                             ('fips-199-low'))"/>
      <xsl:variable name="securitySensitivityLevel" select="."/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test=". eq $security-impact-level"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test=". eq $security-impact-level">
               <xsl:attribute name="id">security-sensitivity-level-matches-security-impact-level</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:value-of xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
                                xmlns:feddoc="http://us.gov/documentation/federal-documentation"
                                xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                                select="$security-level-string"/> -- A FedRAMP SSP security sensitivity level must match the highest level within the security
                impact levels.</svrl:text>
               <svrl:diagnostic-reference diagnostic="security-sensitivity-level-matches-security-impact-level-diagnostic">
This FedRAMP SSP security sensitivity level does not match the
            security impact level.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M47"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:security-impact-level" priority="1001" mode="M47">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:security-impact-level"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:security-objective-confidentiality"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:security-objective-confidentiality">
               <xsl:attribute name="id">has-security-objective-confidentiality</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An OSCAL SSP must specify a confidentiality security objective.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-security-objective-confidentiality-diagnostic">
This FedRAMP SSP lacks a confidentiality security objective.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:security-objective-integrity"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:security-objective-integrity">
               <xsl:attribute name="id">has-security-objective-integrity</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An OSCAL SSP must specify an integrity security objective.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-security-objective-integrity-diagnostic">
This FedRAMP SSP lacks an integrity security objective.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:security-objective-availability"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:security-objective-availability">
               <xsl:attribute name="id">has-security-objective-availability</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An OSCAL SSP must specify an availability security objective.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-security-objective-availability-diagnostic">
This FedRAMP SSP lacks an availability security objective.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M47"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:security-objective-confidentiality | oscal:security-objective-integrity | oscal:security-objective-availability"
                 priority="1000"
                 mode="M47">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:security-objective-confidentiality | oscal:security-objective-integrity | oscal:security-objective-availability"/>
      <xsl:variable name="security-objective-levels"
                    select="$fedramp-values//fedramp:value-set[@name eq 'security-level']//fedramp:enum/@value"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="current() = $security-objective-levels"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="current() = $security-objective-levels">
               <xsl:attribute name="id">has-allowed-security-objective-value</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP must specify an allowed security objective value.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-allowed-security-objective-value-diagnostic">
Invalid "<xsl:text/>
                  <xsl:value-of select="name()"/>
                  <xsl:text/>" <xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>". It must have one of the following <xsl:text/>
                  <xsl:value-of select="count($security-objective-levels)"/>
                  <xsl:text/> values: <xsl:text/>
                  <xsl:value-of select="string-join($security-objective-levels, ' ∨ ')"/>
                  <xsl:text/>.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="impact-name"
                    select="substring-after(substring-after(local-name(), '-'), '-')"/>
      <xsl:variable name="impact-selected"
                    select="string-join(/oscal:system-security-plan/oscal:system-characteristics/oscal:system-information//oscal:information-type//*[contains(local-name(), $impact-name)]/oscal:selected/text())"/>
      <xsl:variable name="impactBase"
                    select="string-join(/oscal:system-security-plan/oscal:system-characteristics/oscal:system-information//oscal:information-type//*[contains(local-name(), $impact-name)]/oscal:base/text())"/>
      <xsl:variable name="security-impact-level-selected"
                    select="                     if (matches($impact-selected, 'high'))                     then                         ('fips-199-high')                     else                         (if (matches($impact-selected, 'moderate'))                         then                             ('fips-199-moderate')                         else                             (if (matches($impact-selected, 'low'))                             then                                 ('fips-199-low')                             else                                 ('fips-199-low')))"/>
      <xsl:variable name="security-impact-level-base"
                    select="                     if (matches($impactBase, 'high'))                     then                         ('fips-199-high')                     else                         (if (matches($impactBase, 'moderate'))                         then                             ('fips-199-moderate')                         else                             (if (matches($impactBase, 'low'))                             then                                 ('fips-199-low')                             else                                 ('fips-199-low')))"/>
      <xsl:variable name="impactValue"
                    select="                     if ($security-impact-level-selected ne '')                     then                         ($security-impact-level-selected)                     else                         ($security-impact-level-base)"/>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="$impactValue eq ."/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$impactValue eq .">
               <xsl:attribute name="id">cia-impact-matches-security-objective</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An SSP security objective value must be the same as highest available value of the same information type
                impact element.</svrl:text>
               <svrl:diagnostic-reference diagnostic="cia-impact-matches-security-objective-diagnostic">
The FedRAMP SSP security objective <xsl:value-of xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
                                xmlns:feddoc="http://us.gov/documentation/federal-documentation"
                                xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                                select="substring-after(substring-after(local-name(), '-'), '-')"/> does not match the <xsl:value-of xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
                                xmlns:feddoc="http://us.gov/documentation/federal-documentation"
                                xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                                select="substring-after(substring-after(local-name(), '-'), '-')"/> impact value.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M47"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M47"/>
   <xsl:template match="@*|node()" priority="-2" mode="M47">
      <xsl:apply-templates select="*" mode="M47"/>
   </xsl:template>
   <!--PATTERN sp800-60SP 800-60v2r1 Information Types:-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">SP 800-60v2r1 Information Types:</svrl:text>
   <!--RULE -->
   <xsl:template match="oscal:system-information" priority="1005" mode="M48">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:system-information"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:information-type"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="oscal:information-type">
               <xsl:attribute name="id">system-information-has-information-type</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An OSCAL SSP must define at least one information type.</svrl:text>
               <svrl:diagnostic-reference diagnostic="system-information-has-information-type-diagnostic">
A FedRAMP SSP lacks at least one information-type.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M48"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:information-type" priority="1004" mode="M48">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:information-type"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:title"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="oscal:title">
               <xsl:attribute name="id">information-type-has-title</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An OSCAL SSP information type must have a title.</svrl:text>
               <svrl:diagnostic-reference diagnostic="information-type-has-title-diagnostic">
An OSCAL SSP information-type lacks a title.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:description"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="oscal:description">
               <xsl:attribute name="id">information-type-has-description</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An OSCAL SSP information type must have a description.</svrl:text>
               <svrl:diagnostic-reference diagnostic="information-type-has-description-diagnostic">
An OSCAL SSP information-type lacks a description.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:categorization"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="oscal:categorization">
               <xsl:attribute name="id">information-type-has-categorization</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP information type must have at least one categorization.</svrl:text>
               <svrl:diagnostic-reference diagnostic="information-type-has-categorization-diagnostic">
A FedRAMP SSP information-type lacks at least one categorization.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:confidentiality-impact"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:confidentiality-impact">
               <xsl:attribute name="id">information-type-has-confidentiality-impact</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An OSCAL SSP information type must have a confidentiality impact.</svrl:text>
               <svrl:diagnostic-reference diagnostic="information-type-has-confidentiality-impact-diagnostic">
An OSCAL SSP information-type lacks a confidentiality-impact.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:integrity-impact"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="oscal:integrity-impact">
               <xsl:attribute name="id">information-type-has-integrity-impact</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An OSCAL SSP information type must have an integrity impact.</svrl:text>
               <svrl:diagnostic-reference diagnostic="information-type-has-integrity-impact-diagnostic">
An OSCAL SSP information-type lacks a integrity-impact.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:availability-impact"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:availability-impact">
               <xsl:attribute name="id">information-type-has-availability-impact</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An OSCAL SSP information type must have an availability impact.</svrl:text>
               <svrl:diagnostic-reference diagnostic="information-type-has-availability-impact-diagnostic">
An OSCAL SSP information-type lacks a availability-impact.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M48"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:categorization" priority="1003" mode="M48">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="oscal:categorization"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@system"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@system">
               <xsl:attribute name="id">categorization-has-system-attribute</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP information type categorization must have a system attribute.</svrl:text>
               <svrl:diagnostic-reference diagnostic="categorization-has-system-attribute-diagnostic">
A FedRAMP SSP information-type categorization lacks a system
            attribute.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@system eq 'https://doi.org/10.6028/NIST.SP.800-60v2r1'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@system eq 'https://doi.org/10.6028/NIST.SP.800-60v2r1'">
               <xsl:attribute name="id">categorization-has-correct-system-attribute</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP information type categorization must have a correct
                system attribute.</svrl:text>
               <svrl:diagnostic-reference diagnostic="categorization-has-correct-system-attribute-diagnostic">
A FedRAMP SSP information-type categorization lacks a correct system
            attribute. The correct value is "https://doi.org/10.6028/NIST.SP.800-60v2r1".</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:information-type-id"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:information-type-id">
               <xsl:attribute name="id">categorization-has-information-type-id</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP information type categorization must have at least one information type
                identifier.</svrl:text>
               <svrl:diagnostic-reference diagnostic="categorization-has-information-type-id-diagnostic">
A FedRAMP SSP information-type categorization lacks at least one
            information-type-id.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M48"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:information-type-id" priority="1002" mode="M48">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:information-type-id"/>
      <xsl:variable name="information-types"
                    select="doc(concat($registry-base-path, '/information-types.xml'))//fedramp:information-type/@id"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="current()[. = $information-types]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="current()[. = $information-types]">
               <xsl:attribute name="id">has-allowed-information-type-id</xsl:attribute>
               <xsl:attribute name="see">https://doi.org/10.6028/NIST.SP.800-60v2r1</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP information type identifier must be chosen from those found in NIST SP
                800-60v2r1.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-allowed-information-type-id-diagnostic">
A FedRAMP SSP information-type-id lacks a SP 800-60v2r1 identifier.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M48"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:confidentiality-impact | oscal:integrity-impact | oscal:availability-impact"
                 priority="1001"
                 mode="M48">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:confidentiality-impact | oscal:integrity-impact | oscal:availability-impact"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:base"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="oscal:base">
               <xsl:attribute name="id">cia-impact-has-base</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An OSCAL SSP information type confidentiality, integrity, or availability impact must specify the base
                impact.</svrl:text>
               <svrl:diagnostic-reference diagnostic="cia-impact-has-base-diagnostic">
An OSCAL SSP information-type confidentiality-, integrity-, or availability-impact lacks a base
            element.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:selected"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="oscal:selected">
               <xsl:attribute name="id">cia-impact-has-selected</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP information type confidentiality, integrity, or availability impact must specify the selected
                impact.</svrl:text>
               <svrl:diagnostic-reference diagnostic="cia-impact-has-selected-diagnostic">
A FedRAMP SSP information-type confidentiality-, integrity-, or availability-impact lacks a
            selected element.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (oscal:base ne oscal:selected) then                         exists(oscal:adjustment-justification)                     else                         true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (oscal:base ne oscal:selected) then exists(oscal:adjustment-justification) else true()">
               <xsl:attribute name="id">cia-impact-has-adjustment-justification</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>When SP 800-60 base and selected impacts levels differ for a given information type, the SSP must
                include a justification for the difference.</svrl:text>
               <svrl:diagnostic-reference diagnostic="cia-impact-has-adjustment-justification-diagnostic">
These SP 800-60 base and selected impact levels differ, but no justification for
            the difference is supplied.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M48"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:base | oscal:selected" priority="1000" mode="M48">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:base | oscal:selected"/>
      <xsl:variable name="fips-199-levels"
                    select="$fedramp-values//fedramp:value-set[@name eq 'security-level']//fedramp:enum/@value"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test=". = $fips-199-levels"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test=". = $fips-199-levels">
               <xsl:attribute name="id">cia-impact-has-approved-fips-categorization</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP must indicate for its information system the appropriate categorization for the respective
                confidentiality, integrity, impact levels of its information types (per FIPS-199).</svrl:text>
               <svrl:diagnostic-reference diagnostic="cia-impact-has-approved-fips-categorization-diagnostic">
This FedRAMP SSP information type's confidentiality, integrity, or
            availability impact level, either the base or selected value, lacks an approved value.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M48"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M48"/>
   <xsl:template match="@*|node()" priority="-2" mode="M48">
      <xsl:apply-templates select="*" mode="M48"/>
   </xsl:template>
   <!--PATTERN sp800-63Digital Identity Determination-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Digital Identity Determination</svrl:text>
   <!--RULE -->
   <xsl:template match="oscal:system-characteristics" priority="1003" mode="M49">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:system-characteristics"/>
      <!--ASSERT information-->
      <xsl:choose>
         <xsl:when test="oscal:prop[@name eq 'identity-assurance-level']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:prop[@name eq 'identity-assurance-level']">
               <xsl:attribute name="id">has-identity-assurance-level</xsl:attribute>
               <xsl:attribute name="role">information</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP may have a Digital Identity Determination identity assurance
                level property.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-identity-assurance-level-diagnostic">
A FedRAMP SSP may lack a Digital Identity Determination identity-assurance-level
            property.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT information-->
      <xsl:choose>
         <xsl:when test="oscal:prop[@name eq 'authenticator-assurance-level']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:prop[@name eq 'authenticator-assurance-level']">
               <xsl:attribute name="id">has-authenticator-assurance-level</xsl:attribute>
               <xsl:attribute name="role">information</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP may have a Digital Identity Determination authenticator
                assurance level property.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-authenticator-assurance-level-diagnostic">
A FedRAMP SSP may lack a Digital Identity Determination authenticator-assurance-level
            property.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT information-->
      <xsl:choose>
         <xsl:when test="oscal:prop[@name eq 'federation-assurance-level']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:prop[@name eq 'federation-assurance-level']">
               <xsl:attribute name="id">has-federation-assurance-level</xsl:attribute>
               <xsl:attribute name="role">information</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP may have a Digital Identity Determination federation assurance
                level property.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-federation-assurance-level-diagnostic">
A FedRAMP SSP may lack a Digital Identity Determination federation-assurance-level
            property.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M49"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:prop[@name eq 'identity-assurance-level']"
                 priority="1002"
                 mode="M49">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:prop[@name eq 'identity-assurance-level']"/>
      <xsl:variable name="identity-assurance-levels"
                    select="$fedramp-values//fedramp:value-set[@name eq 'identity-assurance-level']//fedramp:enum/@value"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@value = $identity-assurance-levels"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@value = $identity-assurance-levels">
               <xsl:attribute name="id">has-allowed-identity-assurance-level</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP should have an allowed Digital Identity Determination identity assurance
                level.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-allowed-identity-assurance-level-diagnostic">
A FedRAMP SSP may lack an allowed Digital Identity Determination
            identity-assurance-level property.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M49"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:prop[@name eq 'authenticator-assurance-level']"
                 priority="1001"
                 mode="M49">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:prop[@name eq 'authenticator-assurance-level']"/>
      <xsl:variable name="authenticator-assurance-levels"
                    select="$fedramp-values//fedramp:value-set[@name eq 'authenticator-assurance-level']//fedramp:enum/@value"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@value = $authenticator-assurance-levels"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@value = $authenticator-assurance-levels">
               <xsl:attribute name="id">has-allowed-authenticator-assurance-level</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP should have an allowed Digital Identity Determination authenticator
                assurance level.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-allowed-authenticator-assurance-level-diagnostic">
A FedRAMP SSP may lack an allowed Digital Identity Determination
            authenticator-assurance-level property.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M49"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:prop[@name eq 'federation-assurance-level']"
                 priority="1000"
                 mode="M49">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:prop[@name eq 'federation-assurance-level']"/>
      <xsl:variable name="federation-assurance-levels"
                    select="$fedramp-values//fedramp:value-set[@name eq 'federation-assurance-level']//fedramp:enum/@value"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@value = $federation-assurance-levels"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@value = $federation-assurance-levels">
               <xsl:attribute name="id">has-allowed-federation-assurance-level</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP should have an allowed Digital Identity Determination federation assurance
                level.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-allowed-federation-assurance-level-diagnostic">
A FedRAMP SSP may lack an allowed Digital Identity Determination
            federation-assurance-level property.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M49"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M49"/>
   <xsl:template match="@*|node()" priority="-2" mode="M49">
      <xsl:apply-templates select="*" mode="M49"/>
   </xsl:template>
   <!--PATTERN system-inventoryFedRAMP OSCAL System Inventory A FedRAMP SSP must define system inventory items FedRAMP SSP property constraints FedRAMP SSP inventory components FedRAMP SSP inventory items-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">FedRAMP OSCAL System Inventory</svrl:text>
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">A FedRAMP SSP must define system inventory items</svrl:text>
   <!--RULE -->
   <xsl:template match="/oscal:system-security-plan/oscal:system-implementation"
                 priority="1012"
                 mode="M50">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/oscal:system-security-plan/oscal:system-implementation"/>
      <doc:rule xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
                xmlns:feddoc="http://us.gov/documentation/federal-documentation"
                xmlns:sch="http://purl.oclc.org/dsdl/schematron">A FedRAMP SSP must incorporate inventory-item elements</doc:rule>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:inventory-item"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="oscal:inventory-item">
               <xsl:attribute name="id">has-inventory-items</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP must incorporate inventory items.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-inventory-items-diagnostic">
This FedRAMP SSP lacks inventory-item elements.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M50"/>
   </xsl:template>
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">FedRAMP SSP property constraints</svrl:text>
   <!--RULE -->
   <xsl:template match="oscal:prop[@name eq 'asset-id']" priority="1010" mode="M50">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:prop[@name eq 'asset-id']"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(//oscal:prop[@name eq 'asset-id'][@value eq current()/@value]) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(//oscal:prop[@name eq 'asset-id'][@value eq current()/@value]) = 1">
               <xsl:attribute name="id">has-unique-asset-id</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Every asset identifier must be unique.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-unique-asset-id-diagnostic">
This asset id <xsl:text/>
                  <xsl:value-of select="@asset-id"/>
                  <xsl:text/> is not unique. An asset id must be unique within the scope of a FedRAMP SSP document.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M50"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:prop[@name eq 'asset-type']"
                 priority="1009"
                 mode="M50">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:prop[@name eq 'asset-type']"/>
      <xsl:variable name="asset-types"
                    select="$fedramp-values//fedramp:value-set[@name eq 'asset-type']//fedramp:enum/@value"/>
      <!--ASSERT information-->
      <xsl:choose>
         <xsl:when test="@value = $asset-types"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@value = $asset-types">
               <xsl:attribute name="id">has-allowed-asset-type</xsl:attribute>
               <xsl:attribute name="role">information</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An asset type should have an allowed value.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-allowed-asset-type-diagnostic">
                  <xsl:text/>
                  <xsl:value-of select="@name"/>
                  <xsl:text/> prop may have an asset type other than FedRAMP ones - this one uses "<xsl:text/>
                  <xsl:value-of select="@value"/>
                  <xsl:text/>".</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M50"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:prop[@name eq 'virtual']" priority="1008" mode="M50">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:prop[@name eq 'virtual']"/>
      <xsl:variable name="virtuals"
                    select="$fedramp-values//fedramp:value-set[@name eq 'virtual']//fedramp:enum/@value"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@value = $virtuals"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@value = $virtuals">
               <xsl:attribute name="id">has-allowed-virtual</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A virtual property must have an allowed value.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-allowed-virtual-diagnostic">
                  <xsl:text/>
                  <xsl:value-of select="name()"/>
                  <xsl:text/> must have an allowed value <xsl:text/>
                  <xsl:value-of select="string-join($virtuals, ' ∨ ')"/>
                  <xsl:text/> (not " <xsl:text/>
                  <xsl:value-of select="@value"/>
                  <xsl:text/>").</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M50"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:prop[@name eq 'public']" priority="1007" mode="M50">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:prop[@name eq 'public']"/>
      <xsl:variable name="publics"
                    select="$fedramp-values//fedramp:value-set[@name eq 'public']//fedramp:enum/@value"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@value = $publics"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@value = $publics">
               <xsl:attribute name="id">has-allowed-public</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A public property must have an allowed value.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-allowed-public-diagnostic">
                  <xsl:text/>
                  <xsl:value-of select="name()"/>
                  <xsl:text/> must have an allowed value <xsl:text/>
                  <xsl:value-of select="string-join($publics, ' ∨ ')"/>
                  <xsl:text/> (not " <xsl:text/>
                  <xsl:value-of select="@value"/>
                  <xsl:text/>").</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M50"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:prop[@name eq 'allows-authenticated-scan']"
                 priority="1006"
                 mode="M50">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:prop[@name eq 'allows-authenticated-scan']"/>
      <xsl:variable name="allows-authenticated-scans"
                    select="$fedramp-values//fedramp:value-set[@name eq 'allows-authenticated-scan']//fedramp:enum/@value"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@value = $allows-authenticated-scans"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@value = $allows-authenticated-scans">
               <xsl:attribute name="id">has-allowed-allows-authenticated-scan</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An allows-authenticated-scan property has an allowed value.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-allowed-allows-authenticated-scan-diagnostic">
                  <xsl:text/>
                  <xsl:value-of select="name()"/>
                  <xsl:text/> must have an allowed value <xsl:text/>
                  <xsl:value-of select="string-join($allows-authenticated-scans, ' ∨ ')"/>
                  <xsl:text/> (not " <xsl:text/>
                  <xsl:value-of select="@value"/>
                  <xsl:text/>").</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M50"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:prop[@name eq 'is-scanned']"
                 priority="1005"
                 mode="M50">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:prop[@name eq 'is-scanned']"/>
      <xsl:variable name="is-scanneds"
                    select="$fedramp-values//fedramp:value-set[@name eq 'is-scanned']//fedramp:enum/@value"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@value = $is-scanneds"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@value = $is-scanneds">
               <xsl:attribute name="id">has-allowed-is-scanned</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>is-scanned property must have an allowed value.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-allowed-is-scanned-diagnostic">
                  <xsl:text/>
                  <xsl:value-of select="name()"/>
                  <xsl:text/> must have an allowed value <xsl:text/>
                  <xsl:value-of select="string-join($is-scanneds, ' ∨ ')"/>
                  <xsl:text/> (not " <xsl:text/>
                  <xsl:value-of select="@value"/>
                  <xsl:text/>").</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M50"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'scan-type']"
                 priority="1004"
                 mode="M50">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'scan-type']"/>
      <xsl:variable name="scan-types"
                    select="$fedramp-values//fedramp:value-set[@name eq 'scan-type']//fedramp:enum/@value"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@value = $scan-types"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@value = $scan-types">
               <xsl:attribute name="id">has-allowed-scan-type</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A scan-type property must have an allowed value.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-allowed-scan-type-diagnostic">
                  <xsl:text/>
                  <xsl:value-of select="name()"/>
                  <xsl:text/> must have an allowed value <xsl:text/>
                  <xsl:value-of select="string-join($scan-types, ' ∨ ')"/>
                  <xsl:text/> (not " <xsl:text/>
                  <xsl:value-of select="@value"/>
                  <xsl:text/>").</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M50"/>
   </xsl:template>
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">FedRAMP SSP inventory components</svrl:text>
   <!--RULE -->
   <xsl:template match="oscal:component" priority="1002" mode="M50">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="oscal:component"/>
      <xsl:variable name="component-types"
                    select="$fedramp-values//fedramp:value-set[@name eq 'component-type']//fedramp:enum/@value"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@type = $component-types"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@type = $component-types">
               <xsl:attribute name="id">component-has-allowed-type</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A component must have an allowed type.</svrl:text>
               <svrl:diagnostic-reference diagnostic="component-has-allowed-type-diagnostic">
                  <xsl:text/>
                  <xsl:value-of select="name()"/>
                  <xsl:text/> must have an allowed component type <xsl:text/>
                  <xsl:value-of select="string-join($component-types, ' ∨ ')"/>
                  <xsl:text/> (not " <xsl:text/>
                  <xsl:value-of select="@type"/>
                  <xsl:text/>").</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     (: not(@uuid = //oscal:inventory-item/oscal:implemented-component/@component-uuid) or :)                     oscal:prop[@name eq 'asset-type']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="(: not(@uuid = //oscal:inventory-item/oscal:implemented-component/@component-uuid) or :) oscal:prop[@name eq 'asset-type']">
               <xsl:attribute name="id">component-has-asset-type</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A component must have an asset type.</svrl:text>
               <svrl:diagnostic-reference diagnostic="component-has-asset-type-diagnostic">
                  <xsl:text/>
                  <xsl:value-of select="name()"/>
                  <xsl:text/> lacks an asset-type property.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not(oscal:prop[@name eq 'asset-type'][2])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(oscal:prop[@name eq 'asset-type'][2])">
               <xsl:attribute name="id">component-has-one-asset-type</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A component must have only one asset type.</svrl:text>
               <svrl:diagnostic-reference diagnostic="component-has-one-asset-type-diagnostic">
                  <xsl:text/>
                  <xsl:value-of select="name()"/>
                  <xsl:text/> has more than one asset-type property.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M50"/>
   </xsl:template>
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">FedRAMP SSP inventory items</svrl:text>
   <!--RULE -->
   <xsl:template match="oscal:inventory-item" priority="1000" mode="M50">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="oscal:inventory-item">
         <xsl:attribute name="see">Guide to OSCAL-based FedRAMP System Security Plans §5.2</xsl:attribute>
      </svrl:fired-rule>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@uuid"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@uuid">
               <xsl:attribute name="id">inventory-item-has-uuid</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An inventory item has a unique identifier.</svrl:text>
               <svrl:diagnostic-reference diagnostic="inventory-item-has-uuid-diagnostic">
This inventory-item lacks a uuid attribute.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:prop[@name eq 'asset-id']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:prop[@name eq 'asset-id']">
               <xsl:attribute name="id">has-asset-id</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An inventory item must have an asset identifier.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-asset-id-diagnostic">
This inventory-item lacks an asset-id property.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not(oscal:prop[@name eq 'asset-id'][2])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(oscal:prop[@name eq 'asset-id'][2])">
               <xsl:attribute name="id">has-one-asset-id</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An inventory item must have only one asset identifier.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-one-asset-id-diagnostic">
This inventory-item has more than one asset-id property.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:prop[@name eq 'asset-type']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:prop[@name eq 'asset-type']">
               <xsl:attribute name="id">inventory-item-has-asset-type</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An inventory item must have an asset-type.</svrl:text>
               <svrl:diagnostic-reference diagnostic="inventory-item-has-asset-type-diagnostic">
This inventory-item lacks an asset-type property.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not(oscal:prop[@name eq 'asset-type'][2])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(oscal:prop[@name eq 'asset-type'][2])">
               <xsl:attribute name="id">inventory-item-has-one-asset-type</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An inventory item must have only one asset-type.</svrl:text>
               <svrl:diagnostic-reference diagnostic="inventory-item-has-one-asset-type-diagnostic">
This inventory-item has more than one asset-type property.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:prop[@name eq 'virtual']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:prop[@name eq 'virtual']">
               <xsl:attribute name="id">inventory-item-has-virtual</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An inventory item must have a virtual property.</svrl:text>
               <svrl:diagnostic-reference diagnostic="inventory-item-has-virtual-diagnostic">
This inventory-item lacks a virtual property.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not(oscal:prop[@name eq 'virtual'][2])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(oscal:prop[@name eq 'virtual'][2])">
               <xsl:attribute name="id">inventory-item-has-one-virtual</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An inventory item must have only one virtual property.</svrl:text>
               <svrl:diagnostic-reference diagnostic="inventory-item-has-one-virtual-diagnostic">
This inventory-item has more than one virtual property.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:prop[@name eq 'public']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:prop[@name eq 'public']">
               <xsl:attribute name="id">inventory-item-has-public</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An inventory item must have a public property.</svrl:text>
               <svrl:diagnostic-reference diagnostic="inventory-item-has-public-diagnostic">
This inventory-item lacks a public property.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not(oscal:prop[@name eq 'public'][2])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(oscal:prop[@name eq 'public'][2])">
               <xsl:attribute name="id">inventory-item-has-one-public</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An inventory item must have only one public property.</svrl:text>
               <svrl:diagnostic-reference diagnostic="inventory-item-has-one-public-diagnostic">
This inventory-item has more than one public property.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:prop[@name eq 'scan-type']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:prop[@name eq 'scan-type']">
               <xsl:attribute name="id">inventory-item-has-scan-type</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An inventory item must have a scan-type property.</svrl:text>
               <svrl:diagnostic-reference diagnostic="inventory-item-has-scan-type-diagnostic">
This inventory-item lacks a scan-type property.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not(oscal:prop[@name eq 'scan-type'][2])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(oscal:prop[@name eq 'scan-type'][2])">
               <xsl:attribute name="id">inventory-item-has-one-scan-type</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An inventory item has only one scan-type property.</svrl:text>
               <svrl:diagnostic-reference diagnostic="inventory-item-has-one-scan-type-diagnostic">
This inventory-item has more than one scan-type property.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="is-infrastructure"
                    select="exists(oscal:prop[@name eq 'asset-type' and @value = ('os', 'infrastructure')])"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not($is-infrastructure) or oscal:prop[@name eq 'allows-authenticated-scan']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not($is-infrastructure) or oscal:prop[@name eq 'allows-authenticated-scan']">
               <xsl:attribute name="id">inventory-item-has-allows-authenticated-scan</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>"infrastructure" inventory item has
                allows-authenticated-scan.</svrl:text>
               <svrl:diagnostic-reference diagnostic="inventory-item-has-allows-authenticated-scan-diagnostic">
This inventory-item lacks allows-authenticated-scan
            property.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not($is-infrastructure) or not(oscal:prop[@name eq 'allows-authenticated-scan'][2])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not($is-infrastructure) or not(oscal:prop[@name eq 'allows-authenticated-scan'][2])">
               <xsl:attribute name="id">inventory-item-has-one-allows-authenticated-scan</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An inventory item has
                one-allows-authenticated-scan property.</svrl:text>
               <svrl:diagnostic-reference diagnostic="inventory-item-has-one-allows-authenticated-scan-diagnostic">
This inventory-item has more than one allows-authenticated-scan
            property.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not($is-infrastructure) or oscal:prop[@name eq 'baseline-configuration-name']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not($is-infrastructure) or oscal:prop[@name eq 'baseline-configuration-name']">
               <xsl:attribute name="id">inventory-item-has-baseline-configuration-name</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>"infrastructure" inventory item has
                baseline-configuration-name.</svrl:text>
               <svrl:diagnostic-reference diagnostic="inventory-item-has-baseline-configuration-name-diagnostic">
This inventory-item lacks baseline-configuration-name
            property.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not($is-infrastructure) or not(oscal:prop[@name eq 'baseline-configuration-name'][2])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not($is-infrastructure) or not(oscal:prop[@name eq 'baseline-configuration-name'][2])">
               <xsl:attribute name="id">inventory-item-has-one-baseline-configuration-name</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>"infrastructure" inventory item has only
                one baseline-configuration-name.</svrl:text>
               <svrl:diagnostic-reference diagnostic="inventory-item-has-one-baseline-configuration-name-diagnostic">
This inventory-item has more than one baseline-configuration-name
            property.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not($is-infrastructure) or oscal:prop[(: @ns eq 'https://fedramp.gov/ns/oscal' and :)@name eq 'vendor-name']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not($is-infrastructure) or oscal:prop[(: @ns eq 'https://fedramp.gov/ns/oscal' and :)@name eq 'vendor-name']">
               <xsl:attribute name="id">inventory-item-has-vendor-name</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> "infrastructure"
                inventory item has a vendor-name property.</svrl:text>
               <svrl:diagnostic-reference diagnostic="inventory-item-has-vendor-name-diagnostic">
This inventory-item lacks a vendor-name property.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not($is-infrastructure) or not(oscal:prop[(: @ns eq 'https://fedramp.gov/ns/oscal' and :)@name eq 'vendor-name'][2])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not($is-infrastructure) or not(oscal:prop[(: @ns eq 'https://fedramp.gov/ns/oscal' and :)@name eq 'vendor-name'][2])">
               <xsl:attribute name="id">inventory-item-has-one-vendor-name</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                "infrastructure" inventory item must have only one vendor-name property.</svrl:text>
               <svrl:diagnostic-reference diagnostic="inventory-item-has-one-vendor-name-diagnostic">
This inventory-item has more than one vendor-name property.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="prohibit-vendor"
                    select="                     ('Dahua Technology Company', 'Dahua',                     'Hangzhou Hikvision Digital Technology', 'Hangzhou',                     'Hikvision', 'Hangzhou Hikvision',                     'Huawei', 'Huawei Technologies Company',                     'HyTera', 'Hytera Communications Corporation',                     'AO Kaspersky Lab', 'Kaspersky Lab', 'Kaspersky',                     'ZTE', 'ZTE Corporation',                     'China Mobile', 'China Mobile International USA Inc',                     'China Telecom', 'China Telecom (Americas) Corp')"/>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="not(oscal:prop[@name eq 'vendor-name']/@value = $prohibit-vendor)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(oscal:prop[@name eq 'vendor-name']/@value = $prohibit-vendor)">
               <xsl:attribute name="id">has-prohibited-vendor-name</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The inventory item does not cite a banned
                vendor.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-prohibited-vendor-name-diagnostic">
This inventory-item contains a banned vendor. Please see
            https://www.fcc.gov/supplychain/coveredlist.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not($is-infrastructure) or oscal:prop[(: @ns eq 'https://fedramp.gov/ns/oscal' and :)@name eq 'hardware-model']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not($is-infrastructure) or oscal:prop[(: @ns eq 'https://fedramp.gov/ns/oscal' and :)@name eq 'hardware-model']">
               <xsl:attribute name="id">inventory-item-has-hardware-model</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                "infrastructure" inventory item must have a hardware-model property.</svrl:text>
               <svrl:diagnostic-reference diagnostic="inventory-item-has-hardware-model-diagnostic">
This inventory-item lacks a hardware-model property.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not($is-infrastructure) or not(oscal:prop[(: @ns eq 'https://fedramp.gov/ns/oscal' and :)@name eq 'hardware-model'][2])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not($is-infrastructure) or not(oscal:prop[(: @ns eq 'https://fedramp.gov/ns/oscal' and :)@name eq 'hardware-model'][2])">
               <xsl:attribute name="id">inventory-item-has-one-hardware-model</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                "infrastructure" inventory item must have only one hardware-model property.</svrl:text>
               <svrl:diagnostic-reference diagnostic="inventory-item-has-one-hardware-model-diagnostic">
This inventory-item has more than one hardware-model property.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not($is-infrastructure) or oscal:prop[@name eq 'is-scanned']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not($is-infrastructure) or oscal:prop[@name eq 'is-scanned']">
               <xsl:attribute name="id">inventory-item-has-is-scanned</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>"infrastructure" inventory item must have is-scanned
                property.</svrl:text>
               <svrl:diagnostic-reference diagnostic="inventory-item-has-is-scanned-diagnostic">
This inventory-item lacks is-scanned property.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not($is-infrastructure) or not(oscal:prop[@name eq 'is-scanned'][2])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not($is-infrastructure) or not(oscal:prop[@name eq 'is-scanned'][2])">
               <xsl:attribute name="id">inventory-item-has-one-is-scanned</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>"infrastructure" inventory item must have only one
                is-scanned property.</svrl:text>
               <svrl:diagnostic-reference diagnostic="inventory-item-has-one-is-scanned-diagnostic">
This inventory-item has more than one is-scanned property.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="is-software-and-database"
                    select="exists(oscal:prop[@name eq 'asset-type' and @value = ('software', 'database')])"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not($is-software-and-database) or oscal:prop[@name eq 'software-name']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not($is-software-and-database) or oscal:prop[@name eq 'software-name']">
               <xsl:attribute name="id">inventory-item-has-software-name</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>"software or database" inventory item must have a
                software-name property.</svrl:text>
               <svrl:diagnostic-reference diagnostic="inventory-item-has-software-name-diagnostic">
This inventory-item lacks software-name property.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not($is-software-and-database) or not(oscal:prop[@name eq 'software-name'][2])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not($is-software-and-database) or not(oscal:prop[@name eq 'software-name'][2])">
               <xsl:attribute name="id">inventory-item-has-one-software-name</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>"software or database" inventory item must have
                a software-name property.</svrl:text>
               <svrl:diagnostic-reference diagnostic="inventory-item-has-one-software-name-diagnostic">
This inventory-item has more than one software-name property.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not($is-software-and-database) or oscal:prop[@name eq 'software-version']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not($is-software-and-database) or oscal:prop[@name eq 'software-version']">
               <xsl:attribute name="id">inventory-item-has-software-version</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>"software or database" inventory item must have a
                software-version property.</svrl:text>
               <svrl:diagnostic-reference diagnostic="inventory-item-has-software-version-diagnostic">
This inventory-item lacks software-version property.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not($is-software-and-database) or not(oscal:prop[@name eq 'software-version'][2])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not($is-software-and-database) or not(oscal:prop[@name eq 'software-version'][2])">
               <xsl:attribute name="id">inventory-item-has-one-software-version</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>"software or database" inventory item must
                have one software-version property.</svrl:text>
               <svrl:diagnostic-reference diagnostic="inventory-item-has-one-software-version-diagnostic">
This inventory-item has more than one software-version property.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not($is-software-and-database) or oscal:prop[@name eq 'function']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not($is-software-and-database) or oscal:prop[@name eq 'function']">
               <xsl:attribute name="id">inventory-item-has-function</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>"software or database" inventory item must have a function
                property.</svrl:text>
               <svrl:diagnostic-reference diagnostic="inventory-item-has-function-diagnostic">
                  <xsl:text/>
                  <xsl:value-of select="name()"/>
                  <xsl:text/> "<xsl:text/>
                  <xsl:value-of select="oscal:prop[@name eq 'asset-type']/@value"/>
                  <xsl:text/>" lacks function property.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="not($is-software-and-database) or not(oscal:prop[@name eq 'function'][2])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not($is-software-and-database) or not(oscal:prop[@name eq 'function'][2])">
               <xsl:attribute name="id">inventory-item-has-one-function</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>"software or database" inventory item must have one
                function property.</svrl:text>
               <svrl:diagnostic-reference diagnostic="inventory-item-has-one-function-diagnostic">
                  <xsl:text/>
                  <xsl:value-of select="name()"/>
                  <xsl:text/> "<xsl:text/>
                  <xsl:value-of select="oscal:prop[@name eq 'asset-type']/@value"/>
                  <xsl:text/>" has more than one function property.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (oscal:prop[@name eq 'ipv4-address'])                     then                         (oscal:prop[@name eq 'ipv6-address'])                     else                         (true())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (oscal:prop[@name eq 'ipv4-address']) then (oscal:prop[@name eq 'ipv6-address']) else (true())">
               <xsl:attribute name="id">inventory-item-network-address</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>If any inventory-item has a prop with a name of 'ipv4-address' it must also have a prop with a name
                of 'ipv6-address'.</svrl:text>
               <svrl:diagnostic-reference diagnostic="inventory-item-network-address-diagnostic">
                  <xsl:text/>
                  <xsl:value-of select="oscal:prop[@name = 'asset-id']/@value"/>
                  <xsl:text/> has an IPv4 address but does not have an IPv6 address.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (oscal:prop[@name eq 'ipv4-address'])                     then                         (oscal:prop[matches(@value, '(^[0-9][0-9]?[0-9]?\.[0-9][0-9]?[0-9]?\.[0-9][0-9]?[0-9]?\.[0-9][0-9]?[0-9]?$)')])                     else                         (true())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (oscal:prop[@name eq 'ipv4-address']) then (oscal:prop[matches(@value, '(^[0-9][0-9]?[0-9]?\.[0-9][0-9]?[0-9]?\.[0-9][0-9]?[0-9]?\.[0-9][0-9]?[0-9]?$)')]) else (true())">
               <xsl:attribute name="id">ipv4-has-content</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:value-of xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
                                xmlns:feddoc="http://us.gov/documentation/federal-documentation"
                                xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                                select="oscal:prop[@name = 'asset-id']/@value"/> must have an appropriate IPv4 value.</svrl:text>
               <svrl:diagnostic-reference diagnostic="ipv4-has-content-diagnostic">
The @value content of prop whose @name is 'ipv4-address' has incorrect content.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:prop[@name eq 'ipv4-address']/@value ne '0.0.0.0'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:prop[@name eq 'ipv4-address']/@value ne '0.0.0.0'">
               <xsl:attribute name="id">ipv4-has-non-placeholder</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:value-of xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
                                xmlns:feddoc="http://us.gov/documentation/federal-documentation"
                                xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                                select="oscal:prop[@name = 'asset-id']/@value"/> must have an appropriate IPv4 value.</svrl:text>
               <svrl:diagnostic-reference diagnostic="ipv4-has-non-placeholder-diagnostic">
The @value content of prop whose @name is 'ipv4-address' has placeholder value of
            0.0.0.0.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="IPv6-regex"
                    select="                     '(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:)                 {1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:)                 {1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]                 {1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:                 ((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))'"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (oscal:prop[@name eq 'ipv6-address'])                     then                         (oscal:prop[matches(@value, $IPv6-regex)])                     else                         (true())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (oscal:prop[@name eq 'ipv6-address']) then (oscal:prop[matches(@value, $IPv6-regex)]) else (true())">
               <xsl:attribute name="id">ipv6-has-content</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:value-of xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
                                xmlns:feddoc="http://us.gov/documentation/federal-documentation"
                                xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                                select="oscal:prop[@name = 'asset-id']/@value"/> must have an appropriate IPv6 value.</svrl:text>
               <svrl:diagnostic-reference diagnostic="ipv6-has-content-diagnostic">
The @value content of prop whose @name is 'ipv6-address' has incorrect content.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (oscal:prop[@name eq 'ipv6-address']/@value eq '::')                     then                         (false())                     else                         (true())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (oscal:prop[@name eq 'ipv6-address']/@value eq '::') then (false()) else (true())">
               <xsl:attribute name="id">ipv6-has-non-placeholder</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:value-of xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
                                xmlns:feddoc="http://us.gov/documentation/federal-documentation"
                                xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                                select="oscal:prop[@name = 'asset-id']/@value"/> must have an appropriate IPv6 value.</svrl:text>
               <svrl:diagnostic-reference diagnostic="ipv6-has-non-placeholder-diagnostic">
The @value content of prop whose @name is 'ipv6-address' has placeholder value of
            ::.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M50"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M50"/>
   <xsl:template match="@*|node()" priority="-2" mode="M50">
      <xsl:apply-templates select="*" mode="M50"/>
   </xsl:template>
   <!--PATTERN basic-system-characteristics-->
   <!--RULE -->
   <xsl:template match="oscal:system-implementation" priority="1001" mode="M51">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:system-implementation">
         <xsl:attribute name="see">Guide to OSCAL-based FedRAMP System Security Plans §6.4.6</xsl:attribute>
      </svrl:fired-rule>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="exists(oscal:component[@type eq 'this-system'])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(oscal:component[@type eq 'this-system'])">
               <xsl:attribute name="id">has-this-system-component</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP must have a self-referential (i.e., to the SSP itself)
                component.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-this-system-component-diagnostic">
This FedRAMP SSP lacks a "this-system" component.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="email-string" select="'email|e-mail|electronic mail'"/>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="                     if (//*[matches(lower-case(.), $email-string)])                     then                         (if (../oscal:control-implementation/oscal:implemented-requirement[@control-id eq 'si-8']//*[matches(., 'DMARC')] and                         ../oscal:control-implementation/oscal:implemented-requirement[@control-id eq 'si-8']//*[matches(., 'SPF')] and                         ../oscal:control-implementation/oscal:implemented-requirement[@control-id eq 'si-8']//*[matches(., 'DKIM')])                         then                             (false())                         else                             (true()))                     else                         (true())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (//*[matches(lower-case(.), $email-string)]) then (if (../oscal:control-implementation/oscal:implemented-requirement[@control-id eq 'si-8']//*[matches(., 'DMARC')] and ../oscal:control-implementation/oscal:implemented-requirement[@control-id eq 'si-8']//*[matches(., 'SPF')] and ../oscal:control-implementation/oscal:implemented-requirement[@control-id eq 'si-8']//*[matches(., 'DKIM')]) then (false()) else (true())) else (true())">
               <xsl:attribute name="id">has-email-and-DMARC</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Email is either absent or sufficiently specified.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-email-and-DMARC-diagnostic">
Email is present but one or more of the following is missing from this SSP: DMARC, SPF, or
            DKIM.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M51"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:system-characteristics" priority="1000" mode="M51">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:system-characteristics"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:system-id[@identifier-type eq 'https://fedramp.gov']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:system-id[@identifier-type eq 'https://fedramp.gov']">
               <xsl:attribute name="id">has-system-id</xsl:attribute>
               <xsl:attribute name="see">Guide to OSCAL-based FedRAMP System Security Plans §4.1.2</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP must have a FedRAMP system identifier.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-system-id-diagnostic">
This FedRAMP SSP lacks a FedRAMP system-id.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:system-name"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="oscal:system-name">
               <xsl:attribute name="id">has-system-name</xsl:attribute>
               <xsl:attribute name="see">Guide to OSCAL-based FedRAMP System Security Plans §4.1.2</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP must have a system name.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-system-name-diagnostic">
This FedRAMP SSP lacks a system-name.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:system-name-short"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="oscal:system-name-short">
               <xsl:attribute name="id">has-system-name-short</xsl:attribute>
               <xsl:attribute name="see">Guide to OSCAL-based FedRAMP System Security Plans §4.1.2</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP must have a short system name.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-system-name-short-diagnostic">
This FedRAMP SSP lacks a system-name-short.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(tokenize(normalize-space(oscal:description), '\s+')) ge 32"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(tokenize(normalize-space(oscal:description), '\s+')) ge 32">
               <xsl:attribute name="id">has-system-description</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP must have a description at least 32 words in
                length.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-system-description-diagnostic">
This FedRAMP SSP has a description less than 32 words in length.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="authorization-types"
                    select="$fedramp-values//fedramp:value-set[@name eq 'authorization-type']//fedramp:enum/@value"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'authorization-type' and @value = $authorization-types]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'authorization-type' and @value = $authorization-types]">
               <xsl:attribute name="id">has-fedramp-authorization-type</xsl:attribute>
               <xsl:attribute name="see">Guide to OSCAL-Based FedRAMP Content Appendix A</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP
                SSP must have an allowed FedRAMP authorization type.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-fedramp-authorization-type-diagnostic">
This FedRAMP SSP lacks a FedRAMP authorization type.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M51"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M51"/>
   <xsl:template match="@*|node()" priority="-2" mode="M51">
      <xsl:apply-templates select="*" mode="M51"/>
   </xsl:template>
   <!--PATTERN fedramp-data-->
   <xsl:variable name="fedramp_data_href"
                 select="'https://raw.githubusercontent.com/18F/fedramp-data/master/data/data.json'"/>
   <xsl:variable name="fedramp_data"
                 select="                 if ($use-remote-resources and unparsed-text-available($fedramp_data_href)) then                     parse-json(unparsed-text($fedramp_data_href))                 else                     nilled(())"/>
   <!--RULE -->
   <xsl:template match="oscal:system-characteristics/oscal:system-id[@identifier-type eq 'https://fedramp.gov']"
                 priority="1001"
                 mode="M52">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:system-characteristics/oscal:system-id[@identifier-type eq 'https://fedramp.gov']"/>
      <xsl:variable name="id" select="current()"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     not($use-remote-resources) or                     (some $p in array:flatten($fedramp_data?data?Providers)                         satisfies $p?Package_ID eq current())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not($use-remote-resources) or (some $p in array:flatten($fedramp_data?data?Providers) satisfies $p?Package_ID eq current())">
               <xsl:attribute name="id">has-active-system-id</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP must have an active FedRAMP system identifier.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-active-system-id-diagnostic">
This FedRAMP SSP does not have an active FedRAMP system identifier.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M52"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:system-security-plan/oscal:system-implementation/oscal:leveraged-authorization"
                 priority="1000"
                 mode="M52">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:system-security-plan/oscal:system-implementation/oscal:leveraged-authorization"/>
      <xsl:variable name="id"
                    select="oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'leveraged-system-identifier']/@value"/>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="                     oscal:prop[                     @ns eq 'https://fedramp.gov/ns/oscal' and                     @name eq 'leveraged-system-identifier' and                     @value ne '']                     "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:prop[ @ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'leveraged-system-identifier' and @value ne '']">
               <xsl:attribute name="id">FedRAMP-ATO-Identifier-exists</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP leveraged authorization must have an identifier.</svrl:text>
               <svrl:diagnostic-reference diagnostic="FedRAMP-ATO-Identifier-exists-diagnostics">
Component _<xsl:value-of xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
                                xmlns:feddoc="http://us.gov/documentation/federal-documentation"
                                xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                                select="oscal:title"/>_ is missing an identifier.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="                     not($use-remote-resources) or                     (some $p in array:flatten($fedramp_data?data?Providers)                         satisfies ($p?Package_ID eq $id and $p?Cloud_Service_Provider_Package eq current()/oscal:title))                     "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not($use-remote-resources) or (some $p in array:flatten($fedramp_data?data?Providers) satisfies ($p?Package_ID eq $id and $p?Cloud_Service_Provider_Package eq current()/oscal:title))">
               <xsl:attribute name="id">has-matching-ATO-identifier</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The FedRAMP leveraged authorization must reference a known Cloud Service Provider Package.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-matching-ATO-identifier-diagnostic">
The FedRAMP Leveraged Authorization title and/or identifier property value does not match a
            Package Identifer in the FedRAMP Authorized Package List.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M52"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M52"/>
   <xsl:template match="@*|node()" priority="-2" mode="M52">
      <xsl:apply-templates select="*" mode="M52"/>
   </xsl:template>
   <!--PATTERN general-rolesRoles, Locations, Parties, Responsibilities-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Roles, Locations, Parties, Responsibilities</svrl:text>
   <!--RULE -->
   <xsl:template match="oscal:metadata" priority="1004" mode="M53">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="oscal:metadata">
         <xsl:attribute name="see">Guide to OSCAL-based FedRAMP System Security Plans §4.2-§4.4</xsl:attribute>
      </svrl:fired-rule>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:role[@id eq 'system-owner']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:role[@id eq 'system-owner']">
               <xsl:attribute name="id">role-defined-system-owner</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The System Owner role must be defined.</svrl:text>
               <svrl:diagnostic-reference diagnostic="role-defined-system-owner-diagnostic">
The system-owner role is missing.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:role[@id eq 'authorizing-official']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:role[@id eq 'authorizing-official']">
               <xsl:attribute name="id">role-defined-authorizing-official</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The Authorizing Official role must be defined.</svrl:text>
               <svrl:diagnostic-reference diagnostic="role-defined-authorizing-official-diagnostic">
The authorizing-official role is missing.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:role[@id eq 'system-poc-management']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:role[@id eq 'system-poc-management']">
               <xsl:attribute name="id">role-defined-system-poc-management</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The System Management PoC role must be defined.</svrl:text>
               <svrl:diagnostic-reference diagnostic="role-defined-system-poc-management-diagnostic">
The system-poc-management role is missing.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:role[@id eq 'system-poc-technical']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:role[@id eq 'system-poc-technical']">
               <xsl:attribute name="id">role-defined-system-poc-technical</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The System Technical PoC role must be defined.</svrl:text>
               <svrl:diagnostic-reference diagnostic="role-defined-system-poc-technical-diagnostic">
The system-poc-technical role is missing.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:role[@id eq 'system-poc-other']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:role[@id eq 'system-poc-other']">
               <xsl:attribute name="id">role-defined-system-poc-other</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The System Other PoC role must be defined.</svrl:text>
               <svrl:diagnostic-reference diagnostic="role-defined-system-poc-other-diagnostic">
The system-poc-other role is missing.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:role[@id eq 'information-system-security-officer']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:role[@id eq 'information-system-security-officer']">
               <xsl:attribute name="id">role-defined-information-system-security-officer</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The Information System Security Officer role must be
                defined.</svrl:text>
               <svrl:diagnostic-reference diagnostic="role-defined-information-system-security-officer-diagnostic">
The information-system-security-officer role is missing.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:role[@id eq 'authorizing-official-poc']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:role[@id eq 'authorizing-official-poc']">
               <xsl:attribute name="id">role-defined-authorizing-official-poc</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The Authorizing Official PoC role must be defined.</svrl:text>
               <svrl:diagnostic-reference diagnostic="role-defined-authorizing-official-poc-diagnostic">
The authorizing-official-poc role is missing.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M53"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:role" priority="1003" mode="M53">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="oscal:role"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:title"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="oscal:title">
               <xsl:attribute name="id">role-has-title</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A role must have a title.</svrl:text>
               <svrl:diagnostic-reference diagnostic="role-has-title-diagnostic">
This role lacks a title.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="//oscal:responsible-party[@role-id eq current()/@id]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="//oscal:responsible-party[@role-id eq current()/@id]">
               <xsl:attribute name="id">role-has-responsible-party</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>One or more responsible parties must be defined for each
                role.</svrl:text>
               <svrl:diagnostic-reference diagnostic="role-has-responsible-party-diagnostic">
This role has no responsible parties.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M53"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:responsible-party" priority="1002" mode="M53">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:responsible-party"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="exists(//oscal:role[@id eq current()/@role-id])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(//oscal:role[@id eq current()/@role-id])">
               <xsl:attribute name="id">responsible-party-has-role</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The role for a responsible party must exist.</svrl:text>
               <svrl:diagnostic-reference diagnostic="responsible-party-has-role-diagnostic">
This responsible-party references a non-existent role.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="exists(oscal:party-uuid)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="exists(oscal:party-uuid)">
               <xsl:attribute name="id">responsible-party-has-party-uuid</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>One or more parties must be identified for a responsibility.</svrl:text>
               <svrl:diagnostic-reference diagnostic="responsible-party-has-party-uuid-diagnostic">
This responsible-party lacks one or more party-uuid elements.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     every $p in oscal:party-uuid                         satisfies exists(//oscal:party[@uuid eq $p])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $p in oscal:party-uuid satisfies exists(//oscal:party[@uuid eq $p])">
               <xsl:attribute name="id">responsible-party-has-definition</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Every responsible party must be defined.</svrl:text>
               <svrl:diagnostic-reference diagnostic="responsible-party-has-definition-diagnostic">
This responsible-party has a party-uuid for a non-existent party.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (                     current()/@role-id = (                     'system-owner',                     'authorizing-official',                     'system-poc-management',                     'system-poc-technical',                     'authorizing-official-poc'                     )                     )                     then                         every $p in oscal:party-uuid                             satisfies                             exists(//oscal:party[@uuid eq $p and @type eq 'person'])                     else                         true()                     "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if ( current()/@role-id = ( 'system-owner', 'authorizing-official', 'system-poc-management', 'system-poc-technical', 'authorizing-official-poc' ) ) then every $p in oscal:party-uuid satisfies exists(//oscal:party[@uuid eq $p and @type eq 'person']) else true()">
               <xsl:attribute name="id">responsible-party-is-person</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>For some roles responsible parties must be persons.</svrl:text>
               <svrl:diagnostic-reference diagnostic="responsible-party-is-person-diagnostic">
This responsible-party references a party which is not a person.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M53"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:party[@type eq 'person']" priority="1001" mode="M53">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:party[@type eq 'person']"/>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="//oscal:responsible-party[oscal:party-uuid = current()/@uuid]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="//oscal:responsible-party[oscal:party-uuid = current()/@uuid]">
               <xsl:attribute name="id">party-has-responsibility</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Each person should have a responsibility.</svrl:text>
               <svrl:diagnostic-reference diagnostic="party-has-responsibility-diagnostic">
This person has no responsibility.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="count(//oscal:responsible-party[oscal:party-uuid = current()/@uuid]) eq 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(//oscal:responsible-party[oscal:party-uuid = current()/@uuid]) eq 1">
               <xsl:attribute name="id">party-has-one-responsibility</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Each person should have no more than one
                responsibility.</svrl:text>
               <svrl:diagnostic-reference diagnostic="party-has-one-responsibility-diagnostic">
                  <xsl:value-of xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
                                xmlns:feddoc="http://us.gov/documentation/federal-documentation"
                                xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                                select="oscal:name"/> - This person has more than one responsibility.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M53"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:location[oscal:prop[@value eq 'data-center']]"
                 priority="1000"
                 mode="M53">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:location[oscal:prop[@value eq 'data-center']]"/>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="count(../oscal:location[oscal:prop[@value eq 'data-center']]) &gt; 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(../oscal:location[oscal:prop[@value eq 'data-center']]) &gt; 1">
               <xsl:attribute name="id">data-center-count</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>There must be at least two (2) data centers
                listed.</svrl:text>
               <svrl:diagnostic-reference diagnostic="data-center-count-diagnostic">
There must be at least two (2) data centers listed.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="count(../oscal:location/oscal:prop[@value eq 'data-center'][@class eq 'primary']) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(../oscal:location/oscal:prop[@value eq 'data-center'][@class eq 'primary']) = 1">
               <xsl:attribute name="id">data-center-primary</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>There is a single primary data
                center.</svrl:text>
               <svrl:diagnostic-reference diagnostic="data-center-primary-diagnostic">
There must be one primary data center location.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="count(../oscal:location/oscal:prop[@value eq 'data-center'][@class eq 'alternate']) &gt; 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(../oscal:location/oscal:prop[@value eq 'data-center'][@class eq 'alternate']) &gt; 0">
               <xsl:attribute name="id">data-center-alternate</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>There is one or more alternate data
                center(s).</svrl:text>
               <svrl:diagnostic-reference diagnostic="data-center-alternate-diagnostic">
There must be one or more alternate data center locations(s).</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="oscal:address/oscal:country"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:address/oscal:country">
               <xsl:attribute name="id">data-center-country-code</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Each data center address must contain a country.</svrl:text>
               <svrl:diagnostic-reference diagnostic="data-center-country-code-diagnostic">
The data center address does not show a country.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="oscal:address/oscal:country eq 'US'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:address/oscal:country eq 'US'">
               <xsl:attribute name="id">data-center-US</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Each data center must have an address that is within the United States.</svrl:text>
               <svrl:diagnostic-reference diagnostic="data-center-US-diagnostic">
The location address for a data center is not within the United States. The country element must contain
            the string 'US'.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M53"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M53"/>
   <xsl:template match="@*|node()" priority="-2" mode="M53">
      <xsl:apply-templates select="*" mode="M53"/>
   </xsl:template>
   <!--PATTERN implementation-rolesRoles related to implemented requirements-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Roles related to implemented requirements</svrl:text>
   <!--RULE -->
   <xsl:template match="oscal:implemented-requirement" priority="1001" mode="M54">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:implemented-requirement">
         <xsl:attribute name="see">https://github.com/GSA/fedramp-automation/issues/233</xsl:attribute>
      </svrl:fired-rule>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     (: implementation-status is not-applicable :)                     exists(oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'implementation-status' and @value eq 'not-applicable'])                     or                     (: responsible-role exists :)                     exists(oscal:responsible-role)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="(: implementation-status is not-applicable :) exists(oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'implementation-status' and @value eq 'not-applicable']) or (: responsible-role exists :) exists(oscal:responsible-role)">
               <xsl:attribute name="id">implemented-requirement-has-responsible-role</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Each implemented control must have one or more responsible-role
                definitions.</svrl:text>
               <svrl:diagnostic-reference diagnostic="implemented-requirement-has-responsible-role-diagnostic">
This implemented-requirement lacks a responsible-role
            definition.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M54"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:responsible-role" priority="1000" mode="M54">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:responsible-role"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="//oscal:role/@id = current()/@role-id"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="//oscal:role/@id = current()/@role-id">
               <xsl:attribute name="id">responsible-role-has-role-definition</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Each responsible-role must reference a role definition.</svrl:text>
               <svrl:diagnostic-reference diagnostic="responsible-role-has-role-definition-diagnostic">
This responsible-role references a non-existent role definition.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="//oscal:role-id = current()/@role-id"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="//oscal:role-id = current()/@role-id">
               <xsl:attribute name="id">responsible-role-has-user</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Each responsible-role must be referenced in a system-implementation user
                assembly.</svrl:text>
               <svrl:diagnostic-reference diagnostic="responsible-role-has-user-diagnostic">
This responsible-role lacks a system-implementation user assembly.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M54"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M54"/>
   <xsl:template match="@*|node()" priority="-2" mode="M54">
      <xsl:apply-templates select="*" mode="M54"/>
   </xsl:template>
   <!--PATTERN user-properties-->
   <!--RULE -->
   <xsl:template match="oscal:user" priority="1007" mode="M55">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="oscal:user"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:role-id"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="oscal:role-id">
               <xsl:attribute name="id">user-has-role-id</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Every user has a role identifier.</svrl:text>
               <svrl:diagnostic-reference diagnostic="user-has-role-id-diagnostic">
This user lacks a role-id.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:prop[@name eq 'type']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:prop[@name eq 'type']">
               <xsl:attribute name="id">user-has-user-type</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Every user has a user type.</svrl:text>
               <svrl:diagnostic-reference diagnostic="user-has-user-type-diagnostic">
This user lacks a user type property.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:prop[@name eq 'privilege-level']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:prop[@name eq 'privilege-level']">
               <xsl:attribute name="id">user-has-privilege-level</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Every user has a privilege-level.</svrl:text>
               <svrl:diagnostic-reference diagnostic="user-has-privilege-level-diagnostic">
This user lacks a privilege-level property.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal'][@name eq 'sensitivity']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal'][@name eq 'sensitivity']">
               <xsl:attribute name="id">user-has-sensitivity-level</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Every user has a sensitivity level.</svrl:text>
               <svrl:diagnostic-reference diagnostic="user-has-sensitivity-level-diagnostic">
This user lacks a sensitivity level property.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:authorized-privilege"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:authorized-privilege">
               <xsl:attribute name="id">user-has-authorized-privilege</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Every user has one or more authorized privileges.</svrl:text>
               <svrl:diagnostic-reference diagnostic="user-has-authorized-privilege-diagnostic">
This user lacks one or more authorized-privileges.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M55"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:user/oscal:role-id" priority="1006" mode="M55">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:user/oscal:role-id"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="//oscal:role[@id eq current()]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="//oscal:role[@id eq current()]">
               <xsl:attribute name="id">role-id-has-role-definition</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Each identified role must reference a role definition.</svrl:text>
               <svrl:diagnostic-reference diagnostic="role-id-has-role-definition-diagnostic">
This role-id references a non-existent role definition.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M55"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:user/oscal:prop[@name eq 'type']"
                 priority="1005"
                 mode="M55">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:user/oscal:prop[@name eq 'type']"/>
      <xsl:variable name="user-types"
                    select="$fedramp-values//fedramp:value-set[@name eq 'user-type']//fedramp:enum/@value"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="current()/@value = $user-types"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="current()/@value = $user-types">
               <xsl:attribute name="id">user-user-type-has-allowed-value</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>User type property has an allowed value.</svrl:text>
               <svrl:diagnostic-reference diagnostic="user-user-type-has-allowed-value-diagnostic">
This user type property lacks an allowed value.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M55"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:user/oscal:prop[@name eq 'privilege-level']"
                 priority="1004"
                 mode="M55">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:user/oscal:prop[@name eq 'privilege-level']"/>
      <xsl:variable name="user-privilege-levels"
                    select="$fedramp-values//fedramp:value-set[@name eq 'user-privilege']//fedramp:enum/@value"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="current()/@value = $user-privilege-levels"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="current()/@value = $user-privilege-levels">
               <xsl:attribute name="id">user-privilege-level-has-allowed-value</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>User privilege level has an allowed value.</svrl:text>
               <svrl:diagnostic-reference diagnostic="user-privilege-level-has-allowed-value-diagnostic">
User privilege-level property has an allowed value.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M55"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:user/oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal'][@name eq 'sensitivity']"
                 priority="1003"
                 mode="M55">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:user/oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal'][@name eq 'sensitivity']"/>
      <xsl:variable name="user-sensitivity-levels"
                    select="$fedramp-values//fedramp:value-set[@name eq 'user-sensitivity-level']//fedramp:enum/@value"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="current()/@value = $user-sensitivity-levels"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="current()/@value = $user-sensitivity-levels">
               <xsl:attribute name="id">user-sensitivity-level-has-allowed-value</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>User sensitivity level has an allowed value.</svrl:text>
               <svrl:diagnostic-reference diagnostic="user-sensitivity-level-has-allowed-value-diagnostic">
This user sensitivity level property lacks an allowed value.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M55"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:user/oscal:authorized-privilege"
                 priority="1002"
                 mode="M55">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:user/oscal:authorized-privilege"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:title"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="oscal:title">
               <xsl:attribute name="id">authorized-privilege-has-title</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>In an OSCAL SSP document every authorized privilege has a title.</svrl:text>
               <svrl:diagnostic-reference diagnostic="authorized-privilege-has-title-diagnostic">
This authorized-privilege lacks a title.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:function-performed"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="oscal:function-performed">
               <xsl:attribute name="id">authorized-privilege-has-function-performed</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>In an OSCAL SSP document every authorized privilege has one or more functions performed.</svrl:text>
               <svrl:diagnostic-reference diagnostic="authorized-privilege-has-function-performed-diagnostic">
This authorized-privilege lacks one or more
            function-performed.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M55"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:authorized-privilege/oscal:title"
                 priority="1001"
                 mode="M55">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:authorized-privilege/oscal:title"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="current() ne ''"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="current() ne ''">
               <xsl:attribute name="id">authorized-privilege-has-non-empty-title</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Every authorized privilege title is not empty.</svrl:text>
               <svrl:diagnostic-reference diagnostic="authorized-privilege-has-non-empty-title-diagnostic">
This authorized-privilege title is empty.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M55"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:authorized-privilege/oscal:function-performed"
                 priority="1000"
                 mode="M55">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:authorized-privilege/oscal:function-performed"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="current() ne ''"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="current() ne ''">
               <xsl:attribute name="id">authorized-privilege-has-non-empty-function-performed</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Every authorized privilege function performed has a definition.</svrl:text>
               <svrl:diagnostic-reference diagnostic="authorized-privilege-has-non-empty-function-performed-diagnostic">
This authorized-privilege lacks a non-empty
            function-performed.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M55"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M55"/>
   <xsl:template match="@*|node()" priority="-2" mode="M55">
      <xsl:apply-templates select="*" mode="M55"/>
   </xsl:template>
   <!--PATTERN authorization-boundaryAuthorization Boundary Diagram-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Authorization Boundary Diagram</svrl:text>
   <!--RULE -->
   <xsl:template match="oscal:system-characteristics" priority="1003" mode="M56">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:system-characteristics"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:authorization-boundary"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:authorization-boundary">
               <xsl:attribute name="id">has-authorization-boundary</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An OSCAL SSP document includes an authorization boundary.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-authorization-boundary-diagnostic">
This OSCAL SSP document lacks an authorization-boundary in its
            system-characteristics.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M56"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:authorization-boundary" priority="1002" mode="M56">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:authorization-boundary"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:description"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="oscal:description">
               <xsl:attribute name="id">has-authorization-boundary-description</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An OSCAL SSP document has an authorization boundary description.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-authorization-boundary-description-diagnostic">
This OSCAL SSP document lacks an authorization-boundary
            description.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="oscal:diagram"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="oscal:diagram">
               <xsl:attribute name="id">has-authorization-boundary-diagram</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP has at least one authorization boundary diagram.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-authorization-boundary-diagram-diagnostic">
This FedRAMP SSP lacks at least one authorization-boundary diagram.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M56"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:authorization-boundary/oscal:diagram"
                 priority="1001"
                 mode="M56">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:authorization-boundary/oscal:diagram"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@uuid"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@uuid">
               <xsl:attribute name="id">has-authorization-boundary-diagram-uuid</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Each OSCAL SSP authorization boundary diagram has a unique identifier.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-authorization-boundary-diagram-uuid-diagnostic">
This FedRAMP SSP authorization-boundary diagram lacks a uuid
            attribute.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:description"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="oscal:description">
               <xsl:attribute name="id">has-authorization-boundary-diagram-description</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An OSCAL SSP document authorization boundary diagram has a description.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-authorization-boundary-diagram-description-diagnostic">
This OSCAL SSP document authorization-boundary diagram lacks a
            description.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:link"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="oscal:link">
               <xsl:attribute name="id">has-authorization-boundary-diagram-link</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Each FedRAMP SSP authorization boundary diagram has a link.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-authorization-boundary-diagram-link-diagnostic">
This FedRAMP SSP authorization-boundary diagram lacks a link.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:caption"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="oscal:caption">
               <xsl:attribute name="id">has-authorization-boundary-diagram-caption</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Each FedRAMP SSP authorization boundary diagram has a caption.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-authorization-boundary-diagram-caption-diagnostic">
This FedRAMP SSP authorization-boundary diagram lacks a
            caption.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M56"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:authorization-boundary/oscal:diagram/oscal:link"
                 priority="1000"
                 mode="M56">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:authorization-boundary/oscal:diagram/oscal:link"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@rel"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@rel">
               <xsl:attribute name="id">has-authorization-boundary-diagram-link-rel</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Each FedRAMP SSP authorization boundary diagram has a link rel attribute.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-authorization-boundary-diagram-link-rel-diagnostic">
This FedRAMP SSP authorization-boundary diagram lacks a link rel
            attribute.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@rel eq 'diagram'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@rel eq 'diagram'">
               <xsl:attribute name="id">has-authorization-boundary-diagram-link-rel-allowed-value</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Each FedRAMP SSP authorization boundary diagram has a link rel attribute with the value
                "diagram".</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-authorization-boundary-diagram-link-rel-allowed-value-diagnostic">
This FedRAMP SSP authorization-boundary diagram lacks a link rel
            attribute with the value "diagram".</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="exists(//oscal:resource[@uuid eq substring-after(current()/@href, '#')])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(//oscal:resource[@uuid eq substring-after(current()/@href, '#')])">
               <xsl:attribute name="id">has-authorization-boundary-diagram-link-href-target</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP authorization boundary diagram link
                references a back-matter resource representing the diagram document.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-authorization-boundary-diagram-link-href-target-diagnostic">
This FedRAMP SSP authorization-boundary diagram link does not
            reference a back-matter resource representing the diagram document.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M56"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M56"/>
   <xsl:template match="@*|node()" priority="-2" mode="M56">
      <xsl:apply-templates select="*" mode="M56"/>
   </xsl:template>
   <!--PATTERN network-architectureNetwork Architecture Diagram-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Network Architecture Diagram</svrl:text>
   <!--RULE -->
   <xsl:template match="oscal:system-characteristics" priority="1003" mode="M57">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:system-characteristics"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:network-architecture"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:network-architecture">
               <xsl:attribute name="id">has-network-architecture</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP includes a network architecture diagram.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-network-architecture-diagnostic">
This FedRAMP SSP lacks an network-architecture in its system-characteristics.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M57"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:network-architecture" priority="1002" mode="M57">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:network-architecture"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:description"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="oscal:description">
               <xsl:attribute name="id">has-network-architecture-description</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP has a network architecture description.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-network-architecture-description-diagnostic">
This FedRAMP SSP lacks an network-architecture description.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="oscal:diagram"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="oscal:diagram">
               <xsl:attribute name="id">has-network-architecture-diagram</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP has at least one network architecture diagram.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-network-architecture-diagram-diagnostic">
This FedRAMP SSP lacks at least one network-architecture diagram.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M57"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:network-architecture/oscal:diagram"
                 priority="1001"
                 mode="M57">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:network-architecture/oscal:diagram"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@uuid"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@uuid">
               <xsl:attribute name="id">has-network-architecture-diagram-uuid</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Each FedRAMP SSP network architecture diagram has a unique identifier.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-network-architecture-diagram-uuid-diagnostic">
This OSCAL SSP document's network-architecture diagram lacks a uuid
            attribute.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:description"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="oscal:description">
               <xsl:attribute name="id">has-network-architecture-diagram-description</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Each FedRAMP SSP network architecture diagram has a description.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-network-architecture-diagram-description-diagnostic">
This FedRAMP SSP network-architecture diagram lacks a
            description.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:link"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="oscal:link">
               <xsl:attribute name="id">has-network-architecture-diagram-link</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Each FedRAMP SSP network architecture diagram has a link.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-network-architecture-diagram-link-diagnostic">
This FedRAMP SSP network-architecture diagram lacks a link.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:caption"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="oscal:caption">
               <xsl:attribute name="id">has-network-architecture-diagram-caption</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Each FedRAMP SSP network architecture diagram has a caption.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-network-architecture-diagram-caption-diagnostic">
This FedRAMP SSP network-architecture diagram lacks a caption.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M57"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:network-architecture/oscal:diagram/oscal:link"
                 priority="1000"
                 mode="M57">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:network-architecture/oscal:diagram/oscal:link"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@rel"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@rel">
               <xsl:attribute name="id">has-network-architecture-diagram-link-rel</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Each FedRAMP SSP network architecture diagram has a link rel attribute.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-network-architecture-diagram-link-rel-diagnostic">
This FedRAMP SSP network-architecture diagram lacks a link rel
            attribute.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@rel eq 'diagram'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@rel eq 'diagram'">
               <xsl:attribute name="id">has-network-architecture-diagram-link-rel-allowed-value</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Each FedRAMP SSP network architecture diagram has a link rel attribute with the value "diagram".</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-network-architecture-diagram-link-rel-allowed-value-diagnostic">
This FedRAMP SSP network-architecture diagram lacks a link rel
            attribute with the value "diagram".</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="exists(//oscal:resource[@uuid eq substring-after(current()/@href, '#')])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(//oscal:resource[@uuid eq substring-after(current()/@href, '#')])">
               <xsl:attribute name="id">has-network-architecture-diagram-link-href-target</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP network architecture diagram link
                references a back-matter resource representing the diagram document.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-network-architecture-diagram-link-href-target-diagnostic">
This FedRAMP SSP network-architecture diagram link does not reference a
            back-matter resource representing the diagram document.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M57"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M57"/>
   <xsl:template match="@*|node()" priority="-2" mode="M57">
      <xsl:apply-templates select="*" mode="M57"/>
   </xsl:template>
   <!--PATTERN data-flowData Flow Diagram-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Data Flow Diagram</svrl:text>
   <!--RULE -->
   <xsl:template match="oscal:system-characteristics" priority="1003" mode="M58">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:system-characteristics"/>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="oscal:data-flow"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="oscal:data-flow">
               <xsl:attribute name="id">has-data-flow</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP includes a data flow diagram.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-data-flow-diagnostic">
This FedRAMP SSP lacks an data-flow in its system-characteristics.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M58"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:data-flow" priority="1002" mode="M58">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="oscal:data-flow"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:description"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="oscal:description">
               <xsl:attribute name="id">has-data-flow-description</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An OSCAL SSP document with a data flow has a description.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-data-flow-description-diagnostic">
This OSCAL SSP document lacks an data-flow description.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="oscal:diagram"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="oscal:diagram">
               <xsl:attribute name="id">has-data-flow-diagram</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP has at least one data flow diagram.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-data-flow-diagram-diagnostic">
This FedRAMP SSP lacks at least one data-flow diagram.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M58"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:data-flow/oscal:diagram" priority="1001" mode="M58">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:data-flow/oscal:diagram"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@uuid"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@uuid">
               <xsl:attribute name="id">has-data-flow-diagram-uuid</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An OSCAL SSP document with a data flow diagram has a unique identifier.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-data-flow-diagram-uuid-diagnostic">
This OSCAL SSP document's data-flow diagram lacks a uuid attribute.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:description"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="oscal:description">
               <xsl:attribute name="id">has-data-flow-diagram-description</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Each FedRAMP SSP data flow diagram has a description.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-data-flow-diagram-description-diagnostic">
This FedRAMP SSP data-flow diagram lacks a description.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:link"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="oscal:link">
               <xsl:attribute name="id">has-data-flow-diagram-link</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Each FedRAMP SSP data flow diagram has a link.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-data-flow-diagram-link-diagnostic">
This FedRAMP SSP data-flow diagram lacks a link.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:caption"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="oscal:caption">
               <xsl:attribute name="id">has-data-flow-diagram-caption</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Each FedRAMP SSP data flow diagram has a caption.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-data-flow-diagram-caption-diagnostic">
This FedRAMP SSP data-flow diagram lacks a caption.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M58"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:data-flow/oscal:diagram/oscal:link"
                 priority="1000"
                 mode="M58">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:data-flow/oscal:diagram/oscal:link"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@rel"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@rel">
               <xsl:attribute name="id">has-data-flow-diagram-link-rel</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Each FedRAMP SSP data flow diagram has a link rel attribute.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-data-flow-diagram-link-rel-diagnostic">
This FedRAMP SSP data-flow diagram lacks a link rel attribute.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@rel eq 'diagram'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@rel eq 'diagram'">
               <xsl:attribute name="id">has-data-flow-diagram-link-rel-allowed-value</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Each FedRAMP SSP data flow diagram has a link rel attribute with the value "diagram".</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-data-flow-diagram-link-rel-allowed-value-diagnostic">
This FedRAMP SSP data-flow diagram lacks a link rel attribute with the value
            "diagram".</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="exists(//oscal:resource[@uuid eq substring-after(current()/@href, '#')])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(//oscal:resource[@uuid eq substring-after(current()/@href, '#')])">
               <xsl:attribute name="id">has-data-flow-diagram-link-href-target</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP data flow diagram link references a
                back-matter resource representing the diagram document.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-data-flow-diagram-link-href-target-diagnostic">
This FedRAMP SSP data-flow diagram link does not reference a back-matter resource
            representing the diagram document.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M58"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M58"/>
   <xsl:template match="@*|node()" priority="-2" mode="M58">
      <xsl:apply-templates select="*" mode="M58"/>
   </xsl:template>
   <!--PATTERN control-implementation-->
   <!--RULE -->
   <xsl:template match="oscal:system-security-plan" priority="1007" mode="M59">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:system-security-plan">
         <xsl:attribute name="see">Guide to OSCAL-based FedRAMP System Security Plans §5.1</xsl:attribute>
      </svrl:fired-rule>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="exists(oscal:import-profile)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(oscal:import-profile)">
               <xsl:attribute name="id">system-security-plan-has-import-profile</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An OSCAL SSP document declares a related OSCAL Profile using an import-profile
                element.</svrl:text>
               <svrl:diagnostic-reference diagnostic="system-security-plan-has-import-profile-diagnostic">
This OSCAL SSP document lacks an import-profile element.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M59"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:import-profile" priority="1006" mode="M59">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="oscal:import-profile">
         <xsl:attribute name="see">Guide to OSCAL-based FedRAMP Security Assessment Results §3.2.1</xsl:attribute>
      </svrl:fired-rule>
      <xsl:variable name="resolved-profile-import-url"
                    select="                     if (starts-with(@href, '#'))                     then                         resolve-uri(/oscal:system-security-plan/oscal:back-matter/oscal:resource[substring-after(current()/@href, '#') = @uuid]/oscal:rlink[1]/@href, base-uri())                     else                         resolve-uri(@href, base-uri())"/>
      <xsl:variable name="resolved-profile-available"
                    select="doc-available($resolved-profile-import-url)"/>
      <xsl:variable name="resolved-profile-doc"
                    select="                     if ($resolved-profile-available)                     then                         doc($resolved-profile-import-url)                     else                         ()"/>
      <!--ASSERT fatal-->
      <xsl:choose>
         <xsl:when test="@href"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@href">
               <xsl:attribute name="id">import-profile-has-href-attribute</xsl:attribute>
               <xsl:attribute name="role">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The import-profile element has a reference.</svrl:text>
               <svrl:diagnostic-reference diagnostic="import-profile-has-href-attribute-diagnostic">
The import-profile element lacks an href attribute.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT fatal-->
      <xsl:choose>
         <xsl:when test="$resolved-profile-available = true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="$resolved-profile-available = true()">
               <xsl:attribute name="id">import-profile-has-available-document</xsl:attribute>
               <xsl:attribute name="role">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The import-profile element references an available document.</svrl:text>
               <svrl:diagnostic-reference diagnostic="import-profile-has-available-document-diagnostic">
The import-profile element has an href attribute that does not reference an
            available document.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT fatal-->
      <xsl:choose>
         <xsl:when test="$resolved-profile-doc/oscal:catalog"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="$resolved-profile-doc/oscal:catalog">
               <xsl:attribute name="id">import-profile-resolves-to-catalog</xsl:attribute>
               <xsl:attribute name="role">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The import-profile element references an available OSCAL resolved baseline profile catalog
                document.</svrl:text>
               <svrl:diagnostic-reference diagnostic="import-profile-resolves-to-catalog-diagnostic">
The import-profile element has an href attribute that does not reference a resolved
            baseline profile catalog document.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M59"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:control-implementation" priority="1005" mode="M59">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:control-implementation"/>
      <xsl:variable name="sensitivity-level" select="/ =&gt; lv:sensitivity-level()"/>
      <xsl:variable name="selected-profile" select="$sensitivity-level =&gt; lv:profile()"/>
      <xsl:variable name="required-controls"
                    select="$selected-profile/*//oscal:control/@id ! xs:string(.)"/>
      <xsl:variable name="implemented-controls"
                    select="oscal:implemented-requirement/@control-id ! xs:string(.)"/>
      <xsl:apply-templates select="*" mode="M59"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:implemented-requirement" priority="1004" mode="M59">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:implemented-requirement"/>
      <xsl:variable name="sensitivity-level" select="/ =&gt; lv:sensitivity-level()"/>
      <xsl:variable name="selected-profile" select="$sensitivity-level =&gt; lv:profile()"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="exists(oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'implementation-status'])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'implementation-status'])">
               <xsl:attribute name="id">implemented-requirement-has-implementation-status</xsl:attribute>
               <xsl:attribute name="see">Guide to OSCAL-based FedRAMP Content §4.9</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Every implemented requirement
                has an implementation-status property.</svrl:text>
               <svrl:diagnostic-reference diagnostic="implemented-requirement-has-implementation-status-diagnostic">
This implemented-requirement lacks an
            implementation-status.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'implementation-status' and @value eq 'planned']) then                         exists(current()/oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'planned-completion-date'])                     else                         true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'implementation-status' and @value eq 'planned']) then exists(current()/oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'planned-completion-date']) else true()">
               <xsl:attribute name="id">implemented-requirement-has-planned-completion-date</xsl:attribute>
               <xsl:attribute name="see">Guide to OSCAL-based FedRAMP Content §4.9</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Planned control implementations have a planned completion date.</svrl:text>
               <svrl:diagnostic-reference diagnostic="implemented-requirement-has-planned-completion-date-diagnostic">
This planned control implementations lacks a planned completion
            date.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'control-origination']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'control-origination']">
               <xsl:attribute name="id">implemented-requirement-has-control-origination</xsl:attribute>
               <xsl:attribute name="see">Guide to OSCAL-based FedRAMP Content §4.9</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Every implemented requirement has a
                control origin.</svrl:text>
               <svrl:diagnostic-reference diagnostic="implemented-requirement-has-control-origination-diagnostic">
This implemented-requirement lacks a control-origination
            property.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="control-originations"
                    select="$fedramp-values//fedramp:value-set[@name eq 'control-origination']//fedramp:enum/@value"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'control-origination' and @value = $control-originations]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'control-origination' and @value = $control-originations]">
               <xsl:attribute name="id">implemented-requirement-has-allowed-control-origination</xsl:attribute>
               <xsl:attribute name="see">Guide to OSCAL-based FedRAMP Content §4.9</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> Every
                implemented requirement has an allowed control origination.</svrl:text>
               <svrl:diagnostic-reference diagnostic="implemented-requirement-has-allowed-control-origination-diagnostic">
This implemented-requirement lacks an allowed control-origination
            property.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'control-origination' and @value eq 'inherited']) then (: there must be a leveraged-authorization-uuid property :)                         exists(oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'leveraged-authorization-uuid']) and (: the referenced leveraged-authorization must exist :) exists(//oscal:leveraged-authorization[@uuid = current()/oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'leveraged-authorization-uuid']/@value])                     else                         true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'control-origination' and @value eq 'inherited']) then (: there must be a leveraged-authorization-uuid property :) exists(oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'leveraged-authorization-uuid']) and (: the referenced leveraged-authorization must exist :) exists(//oscal:leveraged-authorization[@uuid = current()/oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'leveraged-authorization-uuid']/@value]) else true()">
               <xsl:attribute name="id">implemented-requirement-has-leveraged-authorization</xsl:attribute>
               <xsl:attribute name="see">Guide to OSCAL-based FedRAMP Content §4.9</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Every implemented requirement with a control origination of "inherited" references a leveraged
                authorization.</svrl:text>
               <svrl:diagnostic-reference diagnostic="implemented-requirement-has-leveraged-authorization-diagnostic">
This implemented-requirement with a control-origination property of
            "inherited" does not reference a leveraged-authorization element in the same document.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'implementation-status' and @value eq 'partial'])                     then                         exists(oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'implementation-status' and @value eq 'planned'])                     else                         true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'implementation-status' and @value eq 'partial']) then exists(oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'implementation-status' and @value eq 'planned']) else true()">
               <xsl:attribute name="id">partial-implemented-requirement-has-plan</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A partially implemented control must have a plan for complete implementation.</svrl:text>
               <svrl:diagnostic-reference diagnostic="partial-implemented-requirement-has-plan-diagnostic">
This partially complete implemented-requirement is lacking an
            implementation-status of 'planned' and an accompanying date.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     every $c in string-join(distinct-values((oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'implementation-status']/@value)), '-')                         satisfies $c = ('implemented', 'planned', 'alternative', 'not-applicable', 'partial-planned', 'planned-partial')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $c in string-join(distinct-values((oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'implementation-status']/@value)), '-') satisfies $c = ('implemented', 'planned', 'alternative', 'not-applicable', 'partial-planned', 'planned-partial')">
               <xsl:attribute name="id">implemented-requirement-has-allowed-composite-implementation-status</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An
                implemented control's implementation status must be implemented, partial and planned, planned, alternative, or not
                applicable.</svrl:text>
               <svrl:diagnostic-reference diagnostic="implemented-requirement-has-allowed-composite-implementation-status-diagnostic">
This implemented-requirement has an invalid
            implementation-status composition (<xsl:text/>
                  <xsl:value-of select="string-join((oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'implementation-status']/@value), ', ')"/>
                  <xsl:text/>).</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="sensitivity-level"
                    select="/ =&gt; lv:sensitivity-level() =&gt; lv:if-empty-default('')"/>
      <xsl:variable name="selected-profile" select="$sensitivity-level =&gt; lv:profile()"/>
      <xsl:variable name="required-response-points"
                    select="$selected-profile/oscal:catalog//oscal:control[@id = current()/@control-id]/oscal:part[@name = 'statement']/descendant-or-self::oscal:part[oscal:prop[@name = 'response-point']]/@id"/>
      <xsl:variable name="provided-response-points" select="oscal:statement/@statement-id"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     every $i in $selected-profile//oscal:control[@id eq current()/@control-id]/oscal:param[not(oscal:value)]/@id                         satisfies                         exists(oscal:set-parameter[@param-id eq $i])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $i in $selected-profile//oscal:control[@id eq current()/@control-id]/oscal:param[not(oscal:value)]/@id satisfies exists(oscal:set-parameter[@param-id eq $i])">
               <xsl:attribute name="id">set-parameter-elements-match-baseline</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>In the corresponding baseline-resolved-profile catalog, all
                param elements, that do not have child value elements, have an @id value that also occurs in the matching implemented-requirement
                set-parameter element @id in the SSP.</svrl:text>
               <svrl:diagnostic-reference diagnostic="set-parameter-elements-match-baseline-diagnostic">
 For Control <xsl:value-of xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
                                xmlns:feddoc="http://us.gov/documentation/federal-documentation"
                                xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                                select="@control-id"/> - Some values of the SSP set-parameter/@param-id attributes do not match the corresponding control/param/@id
            values in the baseline catalog. SSP set-parameter/@param-id values - <xsl:value-of xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
                                xmlns:feddoc="http://us.gov/documentation/federal-documentation"
                                xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                                select="oscal:set-parameter/@param-id"/> Catalog param/@id values- <xsl:value-of xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
                                xmlns:feddoc="http://us.gov/documentation/federal-documentation"
                                xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                                select="$selected-profile//oscal:control[@id eq current()/@control-id]/oscal:param[not(oscal:value)]/@id"/>.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     every $i in current()//oscal:set-parameter/@param-id                         satisfies                         exists($selected-profile//oscal:control[@id eq current()/@control-id]/oscal:param[@id eq $i])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $i in current()//oscal:set-parameter/@param-id satisfies exists($selected-profile//oscal:control[@id eq current()/@control-id]/oscal:param[@id eq $i])">
               <xsl:attribute name="id">set-parameter-elements-match-baseline1</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>In the SSP, all
                implemented-requirement set-parameter element @id values also occur in the corresponding baseline-resolved-profile catalog param
                elements, that do not have child value elements, @id attributes.</svrl:text>
               <svrl:diagnostic-reference diagnostic="set-parameter-elements-match-baseline1-diagnostic">
 For Control <xsl:value-of xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
                                xmlns:feddoc="http://us.gov/documentation/federal-documentation"
                                xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                                select="@control-id"/> - Some values of the control/param/@id in the baseline catalog do not match the corresponding SSP
            set-parameter/@param-id attribute values. Catalog param/@id values- <xsl:value-of xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
                                xmlns:feddoc="http://us.gov/documentation/federal-documentation"
                                xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                                select="$selected-profile//oscal:control[@id eq current()/@control-id]/oscal:param[not(oscal:value)]/@id"/> SSP
            set-parameter/@param-id values - <xsl:value-of xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
                                xmlns:feddoc="http://us.gov/documentation/federal-documentation"
                                xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                                select="oscal:set-parameter/@param-id"/>.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="                     if (matches(@control-id, 'ia-2.11'))                     then                         (if (self::oscal:implemented-requirement//*[matches(., 'CMVP validated|NIAP Certification|NSA approval')])                         then                             (true())                         else                             (false()))                     else                         (true())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (matches(@control-id, 'ia-2.11')) then (if (self::oscal:implemented-requirement//*[matches(., 'CMVP validated|NIAP Certification|NSA approval')]) then (true()) else (false())) else (true())">
               <xsl:attribute name="id">remote-multi-factor-authentication-described</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Implemented Requirement <xsl:value-of xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
                                xmlns:feddoc="http://us.gov/documentation/federal-documentation"
                                xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                                select="@control-id"/> exists.</svrl:text>
               <svrl:diagnostic-reference diagnostic="remote-multi-factor-authentication-described-diagnostic">
The implemented requirement <xsl:value-of xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
                                xmlns:feddoc="http://us.gov/documentation/federal-documentation"
                                xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                                select="@control-id"/> does not contain the strings 'CMVP validated' or 'NIAP Certification' or 'NSA approval'.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M59"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'implementation-status']"
                 priority="1003"
                 mode="M59">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'implementation-status']"/>
      <xsl:variable name="control-implementation-statuses"
                    select="$fedramp-values//fedramp:value-set[@name eq 'control-implementation-status']//fedramp:enum/@value"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@value = $control-implementation-statuses"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@value = $control-implementation-statuses">
               <xsl:attribute name="id">implemented-requirement-has-allowed-implementation-status</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An implemented control's implementation status has an allowed value.</svrl:text>
               <svrl:diagnostic-reference diagnostic="implemented-requirement-has-allowed-implementation-status-diagnostic">
This implemented control's implementation status lacks an
            allowed value.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if (@value ne 'implemented') then                         oscal:remarks                     else                         true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (@value ne 'implemented') then oscal:remarks else true()">
               <xsl:attribute name="id">implemented-requirement-has-implementation-status-remarks</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Incomplete control implementations have an explanation.</svrl:text>
               <svrl:diagnostic-reference diagnostic="implemented-requirement-has-implementation-status-remarks-diagnostic">
This incomplete control implementation lacks an
            explanation.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M59"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'planned-completion-date']"
                 priority="1002"
                 mode="M59">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'planned-completion-date']"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@value castable as xs:date"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@value castable as xs:date">
               <xsl:attribute name="id">planned-completion-date-is-valid</xsl:attribute>
               <xsl:attribute name="see">Guide to OSCAL-based FedRAMP Content §4.9</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Planned completion date is valid.</svrl:text>
               <svrl:diagnostic-reference diagnostic="planned-completion-date-is-valid-diagnostic">
This planned completion date is not valid.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="not(@value castable as xs:date) or (@value castable as xs:date and xs:date(@value) gt current-date())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(@value castable as xs:date) or (@value castable as xs:date and xs:date(@value) gt current-date())">
               <xsl:attribute name="id">planned-completion-date-is-not-past</xsl:attribute>
               <xsl:attribute name="see">Guide to OSCAL-based FedRAMP Content §4.9</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Planned completion date
                is not past.</svrl:text>
               <svrl:diagnostic-reference diagnostic="planned-completion-date-is-not-past-diagnostic">
This planned completion date references a past time.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M59"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:inherited/oscal:description"
                 priority="1001"
                 mode="M59">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:inherited/oscal:description"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="count(tokenize(normalize-space(.), '\s+')) ge 32"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(tokenize(normalize-space(.), '\s+')) ge 32">
               <xsl:attribute name="id">has-inherited-description</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>An inherited control implementation description must contain at least 32
                words.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-inherited-description-diagnostic">
This inherited control implementation description has less than 32 words.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M59"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:set-parameter" priority="1000" mode="M59">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="oscal:set-parameter"/>
      <xsl:variable name="sensitivity-level"
                    select="/ =&gt; lv:sensitivity-level() =&gt; lv:if-empty-default('')"/>
      <xsl:variable name="selected-profile" select="$sensitivity-level =&gt; lv:profile()"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     if ($selected-profile//oscal:param[@id eq current()/@param-id]/oscal:constraint)                     then                         ($selected-profile//oscal:param[@id eq current()/@param-id][oscal:constraint/oscal:description/oscal:p eq current()/oscal:value])                     else                         (true())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if ($selected-profile//oscal:param[@id eq current()/@param-id]/oscal:constraint) then ($selected-profile//oscal:param[@id eq current()/@param-id][oscal:constraint/oscal:description/oscal:p eq current()/oscal:value]) else (true())">
               <xsl:attribute name="id">uses-correct-param-value</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP must use correct parameter value.</svrl:text>
               <svrl:diagnostic-reference diagnostic="uses-correct-param-value-diagnostic">
The parameter <xsl:value-of xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
                                xmlns:feddoc="http://us.gov/documentation/federal-documentation"
                                xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                                select="current()/@param-id"/> does not match the corresponding baseline resolved profile catalog parameter constraint description
            for the control.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M59"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M59"/>
   <xsl:template match="@*|node()" priority="-2" mode="M59">
      <xsl:apply-templates select="*" mode="M59"/>
   </xsl:template>
   <!--PATTERN cloud-modelsCloud Service and Deployment Models-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Cloud Service and Deployment Models</svrl:text>
   <xsl:variable name="service-models"
                 select="$fedramp-values//fedramp:value-set[@name eq 'service-model']//fedramp:enum/@value"/>
   <xsl:variable name="deployment-models"
                 select="$fedramp-values//fedramp:value-set[@name eq 'deployment-model']//fedramp:enum/@value"/>
   <!--RULE -->
   <xsl:template match="oscal:system-characteristics" priority="1000" mode="M60">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:system-characteristics"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:prop[@name eq 'cloud-service-model']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:prop[@name eq 'cloud-service-model']">
               <xsl:attribute name="id">has-cloud-service-model</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP must define a cloud service model.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-cloud-service-model-diagnostic">
A FedRAMP SSP must specify a cloud service model.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:prop[@name eq 'cloud-service-model' and @value = $service-models]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:prop[@name eq 'cloud-service-model' and @value = $service-models]">
               <xsl:attribute name="id">has-allowed-cloud-service-model</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP must define an allowed cloud service
                model.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-allowed-cloud-service-model-diagnostic">
A FedRAMP SSP must specify an allowed cloud service model.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="oscal:prop[@name eq 'cloud-service-model' and @value = ('saas', 'paas')] and ../oscal:system-implementation/oscal:leveraged-authorization"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:prop[@name eq 'cloud-service-model' and @value = ('saas', 'paas')] and ../oscal:system-implementation/oscal:leveraged-authorization">
               <xsl:attribute name="id">has-leveraged-authorization-with-cloud-service-model</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A
                FedRAMP SSP must define a leveraged authorization for any 'paas' or 'saas' cloud service model.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-leveraged-authorization-with-cloud-service-model-diagnostic">
A FedRAMP SSP with a cloud service model of 'paas' or 'saas' must
            specify a leveraged authorization.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     every $p in oscal:prop[@name eq 'cloud-service-model' and @value eq 'other']                         satisfies exists($p/oscal:remarks)                     "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $p in oscal:prop[@name eq 'cloud-service-model' and @value eq 'other'] satisfies exists($p/oscal:remarks)">
               <xsl:attribute name="id">has-cloud-service-model-remarks</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP with a cloud service model of "other" must supply remarks.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-cloud-service-model-remarks-diagnostic">
A FedRAMP SSP with a cloud service model of "other" must supply remarks.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:prop[@name eq 'cloud-deployment-model']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:prop[@name eq 'cloud-deployment-model']">
               <xsl:attribute name="id">has-cloud-deployment-model</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP must define a cloud deployment model.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-cloud-deployment-model-diagnostic">
A FedRAMP SSP must specify a cloud deployment model.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:prop[@name eq 'cloud-deployment-model' and @value = $deployment-models]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:prop[@name eq 'cloud-deployment-model' and @value = $deployment-models]">
               <xsl:attribute name="id">has-allowed-cloud-deployment-model</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP must define an allowed cloud
                deployment model.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-allowed-cloud-deployment-model-diagnostic">
A FedRAMP SSP must specify an allowed cloud deployment model.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     every $p in oscal:prop[@name eq 'cloud-deployment-model' and @value eq 'hybrid-cloud']                         satisfies exists($p/oscal:remarks)                     "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $p in oscal:prop[@name eq 'cloud-deployment-model' and @value eq 'hybrid-cloud'] satisfies exists($p/oscal:remarks)">
               <xsl:attribute name="id">has-cloud-deployment-model-remarks</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A FedRAMP SSP with a cloud deployment model of "hybrid-cloud" must supply remarks.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-cloud-deployment-model-remarks-diagnostic">
A FedRAMP SSP with a cloud deployment model of "hybrid-cloud" must supply
            remarks.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     (: either there is no component or inventory-item tagged as 'public' :)                     not(                     exists(//oscal:component[oscal:prop[@name eq 'public' and @value eq 'yes']])                     or                     exists(//oscal:inventory-item[oscal:prop[@name eq 'public' and @value eq 'yes']])                     )                     or (: a 'public-cloud' deployment model is employed :)                     exists(oscal:prop[@name eq 'cloud-deployment-model' and @value eq 'public-cloud'])                     "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="(: either there is no component or inventory-item tagged as 'public' :) not( exists(//oscal:component[oscal:prop[@name eq 'public' and @value eq 'yes']]) or exists(//oscal:inventory-item[oscal:prop[@name eq 'public' and @value eq 'yes']]) ) or (: a 'public-cloud' deployment model is employed :) exists(oscal:prop[@name eq 'cloud-deployment-model' and @value eq 'public-cloud'])">
               <xsl:attribute name="id">has-public-cloud-deployment-model</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>When a FedRAMP SSP has public components or inventory items, a cloud deployment model of "public-cloud" must be
                employed.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-public-cloud-deployment-model-diagnostic">
When a FedRAMP SSP has public components or inventory items, a cloud deployment model of
            "public-cloud" must be employed.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M60"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M60"/>
   <xsl:template match="@*|node()" priority="-2" mode="M60">
      <xsl:apply-templates select="*" mode="M60"/>
   </xsl:template>
   <!--PATTERN interconnectsInterconnections-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Interconnections</svrl:text>
   <!--RULE -->
   <xsl:template match="oscal:component[@type = 'interconnection']/oscal:prop[@name eq 'interconnection-direction']"
                 priority="1004"
                 mode="M61">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:component[@type = 'interconnection']/oscal:prop[@name eq 'interconnection-direction']"/>
      <xsl:variable name="interconnection-direction-values"
                    select="$fedramp-values//fedramp:value-set[@name eq 'interconnection-direction']//fedramp:enum/@value"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@value = $interconnection-direction-values"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@value = $interconnection-direction-values">
               <xsl:attribute name="id">interconnection-has-allowed-interconnection-direction-value</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A system interconnection must have an allowed
                interconnection-direction.</svrl:text>
               <svrl:diagnostic-reference diagnostic="interconnection-has-allowed-interconnection-direction-value-diagnostic">
A system interconnection lacks an allowed
            interconnection-direction to explain data direction for information transmitted.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M61"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:component[@type = 'interconnection']/oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'interconnection-security']"
                 priority="1003"
                 mode="M61">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:component[@type = 'interconnection']/oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'interconnection-security']"/>
      <xsl:variable name="interconnection-security-values"
                    select="$fedramp-values//fedramp:value-set[@name eq 'interconnection-security']//fedramp:enum/@value"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@value = $interconnection-security-values"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@value = $interconnection-security-values">
               <xsl:attribute name="id">interconnection-has-allowed-interconnection-security-value</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A system interconnection must have an allowed interconnection-security
                value.</svrl:text>
               <svrl:diagnostic-reference diagnostic="interconnection-has-allowed-interconnection-security-value-diagnostic">
A system interconnection lacks an allowed
            interconnection-security that explains what kind of methods are used to secure information transmitted while in transit.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@value ne 'other' or exists(oscal:remarks)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@value ne 'other' or exists(oscal:remarks)">
               <xsl:attribute name="id">interconnection-has-interconnection-security-remarks</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A system interconnection with an interconnection-security of "other" must
                have explanatory remarks.</svrl:text>
               <svrl:diagnostic-reference diagnostic="interconnection-has-allowed-interconnection-security-remarks-diagnostic">
This system interconnection defines an alternate method for
            securing information in transit, where interconnection-security is defined as "other" and the required explanatory remarks are
            missing.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M61"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:component[@type eq 'interconnection']"
                 priority="1002"
                 mode="M61">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:component[@type eq 'interconnection']"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:title"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="oscal:title">
               <xsl:attribute name="id">interconnection-has-title</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A system interconnection must provide a remote system name.</svrl:text>
               <svrl:diagnostic-reference diagnostic="interconnection-has-title-diagnostic">
This system interconnection lacks a remote system name.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:description"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="oscal:description">
               <xsl:attribute name="id">interconnection-has-description</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A system interconnection must provide a remote system description.</svrl:text>
               <svrl:diagnostic-reference diagnostic="interconnection-has-description-diagnostic">
This system interconnection lacks a remote system description.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:prop[@name eq 'interconnection-direction']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:prop[@name eq 'interconnection-direction']">
               <xsl:attribute name="id">interconnection-has-direction</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A system interconnection must identify the direction of data
                flows.</svrl:text>
               <svrl:diagnostic-reference diagnostic="interconnection-has-direction-diagnostic">
This system interconnection lacks the direction of data flows.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'information']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'information']">
               <xsl:attribute name="id">interconnection-has-information</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A system interconnection must describe the
                information being transferred.</svrl:text>
               <svrl:diagnostic-reference diagnostic="interconnection-has-information-diagnostic">
This system interconnection does not describe the information being
            transferred.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:protocol"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="oscal:protocol">
               <xsl:attribute name="id">interconnection-has-protocol</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A system interconnection must describe the protocols used for information transfer.</svrl:text>
               <svrl:diagnostic-reference diagnostic="interconnection-has-protocol-diagnostic">
A system interconnection does not describe the protocols used for information
            transfer.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'service-processor']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'service-processor']">
               <xsl:attribute name="id">interconnection-has-service-processor</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A system interconnection must describe the
                service processor.</svrl:text>
               <svrl:diagnostic-reference diagnostic="interconnection-has-service-processor-diagnostic">
This system interconnection does not describe the service
            processor.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     (oscal:prop[@name eq 'ipv4-address' and @class eq 'local'] and oscal:prop[@name eq 'ipv4-address' and @class eq 'remote'])                     or                     (oscal:prop[@name eq 'ipv6-address' and @class eq 'local'] and oscal:prop[@name eq 'ipv6-address' and @class eq 'remote'])                     "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="(oscal:prop[@name eq 'ipv4-address' and @class eq 'local'] and oscal:prop[@name eq 'ipv4-address' and @class eq 'remote']) or (oscal:prop[@name eq 'ipv6-address' and @class eq 'local'] and oscal:prop[@name eq 'ipv6-address' and @class eq 'remote'])">
               <xsl:attribute name="id">interconnection-has-local-and-remote-addresses</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A system interconnection must define local and remote network addresses.</svrl:text>
               <svrl:diagnostic-reference diagnostic="interconnection-has-local-and-remote-addresses-diagnostic">
This system interconnection does not specify local and remote network
            addresses.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'interconnection-security']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'interconnection-security']">
               <xsl:attribute name="id">interconnection-has-interconnection-security</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A system interconnection must define
                how the connection is secured.</svrl:text>
               <svrl:diagnostic-reference diagnostic="interconnection-has-interconnection-security-diagnostic">
This system interconnection does not specify how the connection is
            secured.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT information-->
      <xsl:choose>
         <xsl:when test="oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'circuit']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:prop[@ns eq 'https://fedramp.gov/ns/oscal' and @name eq 'circuit']">
               <xsl:attribute name="id">interconnection-has-circuit</xsl:attribute>
               <xsl:attribute name="role">information</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A system interconnection which uses a dedicated
                circuit switching network must specify the circuit number.</svrl:text>
               <svrl:diagnostic-reference diagnostic="interconnection-has-circuit-diagnostic">
This system interconnection does not specify the port or circuit used.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:responsible-role[@role-id eq 'isa-poc-local']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:responsible-role[@role-id eq 'isa-poc-local']">
               <xsl:attribute name="id">interconnection-has-isa-poc-local</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A system interconnection must specify a responsible local (CSP) point of
                contact.</svrl:text>
               <svrl:diagnostic-reference diagnostic="interconnection-has-isa-poc-local-diagnostic">
This system interconnection does not specify a responsible local (CSP) point of
            contact.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:responsible-role[@role-id eq 'isa-poc-remote']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:responsible-role[@role-id eq 'isa-poc-remote']">
               <xsl:attribute name="id">interconnection-has-isa-poc-remote</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A system interconnection must specify a responsible remote point of
                contact.</svrl:text>
               <svrl:diagnostic-reference diagnostic="interconnection-has-isa-poc-remote-diagnostic">
This system interconnection does not specify a responsible remote point of
            contact.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:responsible-role[@role-id eq 'isa-authorizing-official-local']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:responsible-role[@role-id eq 'isa-authorizing-official-local']">
               <xsl:attribute name="id">interconnection-has-isa-authorizing-official-local</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A system interconnection must specify a local authorizing
                official.</svrl:text>
               <svrl:diagnostic-reference diagnostic="interconnection-has-isa-authorizing-official-local-diagnostic">
This system interconnection does not specify a local authorizing
            official.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:responsible-role[@role-id eq 'isa-authorizing-official-remote']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:responsible-role[@role-id eq 'isa-authorizing-official-remote']">
               <xsl:attribute name="id">interconnection-has-isa-authorizing-official-remote</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A system interconnection must specify a remote
                authorizing official.</svrl:text>
               <svrl:diagnostic-reference diagnostic="interconnection-has-isa-authorizing-official-remote-diagnostic">
This system interconnection does not specify a remote authorizing
            official.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     exists(oscal:responsible-role/oscal:party-uuid) and                     (every $rp in descendant::oscal:party-uuid                         satisfies exists(//oscal:party[@uuid eq $rp and @type eq 'person']))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(oscal:responsible-role/oscal:party-uuid) and (every $rp in descendant::oscal:party-uuid satisfies exists(//oscal:party[@uuid eq $rp and @type eq 'person']))">
               <xsl:attribute name="id">interconnection-has-responsible-persons</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Every responsible person for a system
                interconnect is defined.</svrl:text>
               <svrl:diagnostic-reference diagnostic="interconnection-has-responsible-persons-diagnostic">
Not every responsible person for this system interconnect is
            defined.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     every $p in oscal:responsible-role[matches(@role-id, 'local$')]/oscal:party-uuid                         satisfies not($p = oscal:responsible-role[matches(@role-id, 'remote$')]/oscal:party-uuid)                     "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $p in oscal:responsible-role[matches(@role-id, 'local$')]/oscal:party-uuid satisfies not($p = oscal:responsible-role[matches(@role-id, 'remote$')]/oscal:party-uuid)">
               <xsl:attribute name="id">interconnection-has-distinct-isa-local</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A system interconnection must define local responsible parties which are not remote responsible
                parties.</svrl:text>
               <svrl:diagnostic-reference diagnostic="interconnection-has-distinct-isa-local-diagnostic">
This system interconnection has local responsible parties which are also remote
            responsible parties.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     every $p in oscal:responsible-role[matches(@role-id, 'remote$')]/oscal:party-uuid                         satisfies not($p = oscal:responsible-role[matches(@role-id, 'local$')]/oscal:party-uuid)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $p in oscal:responsible-role[matches(@role-id, 'remote$')]/oscal:party-uuid satisfies not($p = oscal:responsible-role[matches(@role-id, 'local$')]/oscal:party-uuid)">
               <xsl:attribute name="id">interconnection-has-distinct-isa-remote</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A system
                interconnection must define remote responsible parties which are not local responsible parties.</svrl:text>
               <svrl:diagnostic-reference diagnostic="interconnection-has-distinct-isa-remote-diagnostic">
This system interconnection has remote responsible parties which are also local
            responsible parties.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:link[@rel eq 'isa-agreement']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:link[@rel eq 'isa-agreement']">
               <xsl:attribute name="id">interconnection-cites-interconnection-agreement</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A system interconnection must cite an interconnection agreement.</svrl:text>
               <svrl:diagnostic-reference diagnostic="interconnection-cites-interconnection-agreement-diagnostic">
This system interconnection does not cite an interconnection
            agreement.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="oscal:link[@rel eq 'isa-agreement' and matches(@href, '^#')]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="oscal:link[@rel eq 'isa-agreement' and matches(@href, '^#')]">
               <xsl:attribute name="id">interconnection-cites-interconnection-agreement-href</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A system interconnection must cite an intra-document defined
                interconnection agreement.</svrl:text>
               <svrl:diagnostic-reference diagnostic="interconnection-cites-interconnection-agreement-href-diagnostic">
This system interconnection does not cite an intra-document defined
            interconnection agreement.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="                     every $href in oscal:link[@rel eq 'agreement']/@href                         satisfies exists(//oscal:resource[@uuid eq substring-after($href, '#')])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $href in oscal:link[@rel eq 'agreement']/@href satisfies exists(//oscal:resource[@uuid eq substring-after($href, '#')])">
               <xsl:attribute name="id">interconnection-cites-attached-interconnection-agreement</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A system interconnection must cite
                an intra-document attached interconnection agreement and that agreement must be present in the SSP.</svrl:text>
               <svrl:diagnostic-reference diagnostic="interconnection-cites-attached-interconnection-agreement-diagnostic">
This system interconnection cites an absent interconnection
            agreement.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M61"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:component[@type eq 'interconnection']/oscal:protocol"
                 priority="1001"
                 mode="M61">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:component[@type eq 'interconnection']/oscal:protocol"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@name"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@name">
               <xsl:attribute name="id">interconnection-protocol-has-name</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A system interconnection protocol must have a name.</svrl:text>
               <svrl:diagnostic-reference diagnostic="interconnection-protocol-has-name-diagnostic">
This system interconnection protocol lacks a name.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT warning-->
      <xsl:choose>
         <xsl:when test="oscal:port-range"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="oscal:port-range">
               <xsl:attribute name="id">interconnection-protocol-has-port-range</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A system interconnection protocol should have one or more port range declarations.</svrl:text>
               <svrl:diagnostic-reference diagnostic="interconnection-protocol-has-port-range-diagnostic">
This system interconnection protocol lacks one or more port range
            declarations.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M61"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:component[@type eq 'interconnection']/oscal:protocol/oscal:port-range"
                 priority="1000"
                 mode="M61">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:component[@type eq 'interconnection']/oscal:protocol/oscal:port-range"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@transport"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@transport">
               <xsl:attribute name="id">interconnection-protocol-port-range-has-transport</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A system interconnection protocol port range declaration must state a transport protocol.</svrl:text>
               <svrl:diagnostic-reference diagnostic="interconnection-protocol-port-range-has-transport-diagnostic">
This system interconnection protocol port range declaration does not
            state a transport protocol.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@start"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@start">
               <xsl:attribute name="id">interconnection-protocol-port-range-has-start</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A system interconnection protocol port range declaration must state a starting port number.</svrl:text>
               <svrl:diagnostic-reference diagnostic="interconnection-protocol-port-range-has-start-diagnostic">
A system interconnection protocol port range declaration does not state a
            starting port number.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="@end"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@end">
               <xsl:attribute name="id">interconnection-protocol-port-range-has-end</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A system interconnection protocol port range declaration must state an ending port number. The start and end port number
                can be the same if there is one port number.</svrl:text>
               <svrl:diagnostic-reference diagnostic="interconnection-protocol-port-range-has-end-diagnostic">
A system interconnection protocol port range declaration does not state an
            ending port number.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M61"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M61"/>
   <xsl:template match="@*|node()" priority="-2" mode="M61">
      <xsl:apply-templates select="*" mode="M61"/>
   </xsl:template>
   <!--PATTERN protocols-->
   <!--RULE -->
   <xsl:template match="oscal:system-implementation" priority="1000" mode="M62">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:system-implementation"/>
      <xsl:variable name="expected-network-protocols"
                    select="'DNS', 'NTP', 'SSH', 'HTTPS', 'TLS'"/>
      <!--ASSERT information-->
      <xsl:choose>
         <xsl:when test="                     every $p in $expected-network-protocols                         satisfies exists(//oscal:protocol[upper-case(@name) eq $p])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $p in $expected-network-protocols satisfies exists(//oscal:protocol[upper-case(@name) eq $p])">
               <xsl:attribute name="id">has-expected-network-protocols</xsl:attribute>
               <xsl:attribute name="role">information</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>All expected network protocols are
                specified.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-expected-network-protocols-diagnostic">
One or more expected network protocols were not defined (within components). The expected
            network protocols are <xsl:text/>
                  <xsl:value-of select="string-join($expected-network-protocols, ', ')"/>
                  <xsl:text/>.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M62"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M62"/>
   <xsl:template match="@*|node()" priority="-2" mode="M62">
      <xsl:apply-templates select="*" mode="M62"/>
   </xsl:template>
   <!--PATTERN dns-->
   <!--RULE -->
   <xsl:template match="oscal:system-implementation" priority="1002" mode="M63">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:system-implementation"/>
      <!--ASSERT information-->
      <xsl:choose>
         <xsl:when test="exists(oscal:component[@type eq 'DNS-authoritative-service'])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(oscal:component[@type eq 'DNS-authoritative-service'])">
               <xsl:attribute name="id">has-DNS-authoritative-service</xsl:attribute>
               <xsl:attribute name="role">information</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>A DNS authoritative service is defined.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-DNS-authoritative-service-diagnostic">
No DNS authoritative service is specified in the SSP.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M63"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:component[@type eq 'DNS-authoritative-service']"
                 priority="1001"
                 mode="M63">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:component[@type eq 'DNS-authoritative-service']"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="exists(oscal:prop[@name eq 'DNS-zone' and exists(@value)])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(oscal:prop[@name eq 'DNS-zone' and exists(@value)])">
               <xsl:attribute name="id">has-DNS-zone</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>The DNS authoritative service has one or more zones
                specified.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-DNS-zone-diagnostic">
A DNS authoritative service is specified but no zones are specified.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M63"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="oscal:component[$use-remote-resources][@type eq 'DNS-authoritative-service' and oscal:status/@state eq 'operational']/oscal:prop[@name eq 'DNS-zone']"
                 priority="1000"
                 mode="M63">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:component[$use-remote-resources][@type eq 'DNS-authoritative-service' and oscal:status/@state eq 'operational']/oscal:prop[@name eq 'DNS-zone']"/>
      <xsl:variable name="zone-regex"
                    select="'^ ([a-z0-9]+ (-[a-z0-9]+)*\.)+ [a-z]{2,} \.? $'"/>
      <xsl:variable name="well-formed" select="matches(@value, $zone-regex, 'ix')"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="$well-formed"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$well-formed">
               <xsl:attribute name="id">has-well-formed-DNS-zone</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Each zone name for the DNS authoritative service is well-formed.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-well-formed-DNS-zone-diagnostic">
The DNS zone "<xsl:text/>
                  <xsl:value-of select="@value"/>
                  <xsl:text/>" is not well-formed.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="DoH-target"
                    select="                     if (ends-with(@value, '.')) then                         @value                     else                         concat(@value, '.')"/>
      <xsl:variable name="DoH_query"
                    select="concat('https://dns.google/resolve?name=', $DoH-target, '&amp;type=SOA')"/>
      <xsl:variable name="DoH-response"
                    select="                     if ($well-formed) then                         unparsed-text($DoH_query)                     else                         ()"/>
      <xsl:variable name="response"
                    select="                     if ($well-formed) then                         parse-json($DoH-response)                     else                         ()"/>
      <xsl:variable name="has-resolved-zone"
                    select="                     if ($well-formed) then                         $response?Status eq 0 and map:contains($response, 'Answer')                     else                         false()"/>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="$has-resolved-zone"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$has-resolved-zone">
               <xsl:attribute name="id">has-resolved-zone</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Each zone for the DNS authoritative service can be resolved.</svrl:text>
               <svrl:diagnostic-reference diagnostic="has-resolved-zone-diagnostic">
The DNS zone "<xsl:text/>
                  <xsl:value-of select="@value"/>
                  <xsl:text/>" did not resolve.</svrl:diagnostic-reference>
               <svrl:diagnostic-reference diagnostic="DoH-response">
The DNS query returned <xsl:text/>
                  <xsl:value-of select="$DoH-response"/>
                  <xsl:text/>.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT error-->
      <xsl:choose>
         <xsl:when test="$has-resolved-zone and $response?AD eq true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="$has-resolved-zone and $response?AD eq true()">
               <xsl:attribute name="id">zone-has-DNSSEC</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Each zone for the DNS authoritative service has DNSSEC.</svrl:text>
               <svrl:diagnostic-reference diagnostic="zone-has-DNSSEC-diagnostic">
The DNS zone "<xsl:text/>
                  <xsl:value-of select="@value"/>
                  <xsl:text/>" lacks DNSSEC.</svrl:diagnostic-reference>
               <svrl:diagnostic-reference diagnostic="DoH-response">
The DNS query returned <xsl:text/>
                  <xsl:value-of select="$DoH-response"/>
                  <xsl:text/>.</svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M63"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M63"/>
   <xsl:template match="@*|node()" priority="-2" mode="M63">
      <xsl:apply-templates select="*" mode="M63"/>
   </xsl:template>
   <!--PATTERN info-->
   <!--RULE -->
   <xsl:template match="oscal:system-security-plan" priority="1000" mode="M64">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="oscal:system-security-plan"/>
      <!--REPORT information-->
      <xsl:if test="true()">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="true()">
            <xsl:attribute name="id">info-system-name</xsl:attribute>
            <xsl:attribute name="role">information</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
               <xsl:text/>
               <xsl:value-of select="oscal:system-characteristics/oscal:system-name"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <!--REPORT information-->
      <xsl:if test="true()">
         <svrl:successful-report xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="true()">
            <xsl:attribute name="id">info-ssp-title</xsl:attribute>
            <xsl:attribute name="role">information</xsl:attribute>
            <xsl:attribute name="location">
               <xsl:apply-templates select="." mode="schematron-select-full-path"/>
            </xsl:attribute>
            <svrl:text>
               <xsl:text/>
               <xsl:value-of select="oscal:metadata/oscal:title"/>
               <xsl:text/>
            </svrl:text>
         </svrl:successful-report>
      </xsl:if>
      <xsl:apply-templates select="*" mode="M64"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M64"/>
   <xsl:template match="@*|node()" priority="-2" mode="M64">
      <xsl:apply-templates select="*" mode="M64"/>
   </xsl:template>
</xsl:stylesheet>
