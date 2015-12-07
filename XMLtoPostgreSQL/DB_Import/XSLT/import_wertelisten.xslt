<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:math="/java.lang.Math" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:fn="http://www.w3.org/2004/10/xpath-functions" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:OpenInfRA="OpenInfRA" xmlns:uuid="java:java.util.UUid">
	<xsl:output method="text" indent="yes"/>
	<xsl:variable name="apos" select='"&apos;"'/>
	<xsl:param name="spath" select="spath"/>

	<xsl:template match="/*">
		<xsl:result-document method="text" href="SQL_Script/Import_wertelisten.sql">
			<xsl:value-of select="concat('SET search_path TO &quot;',$spath,'&quot;, constraints, public;')"/>
			<xsl:text>&#10;</xsl:text>
			<xsl:value-of select="'ALTER TABLE value_list_values DISABLE TRIGGER ALL;'"/>
			<xsl:text>&#10;</xsl:text>
			<xsl:apply-templates select="//OpenInfRA:value_list"/>
			<xsl:apply-templates select="//OpenInfRA:value_list_value"/>
			<xsl:apply-templates select="//OpenInfRA:value_list/OpenInfRA:rel_value_list"/>
			<xsl:apply-templates select="//OpenInfRA:value_list_value/OpenInfRA:rel_value_list_value"/>
			<xsl:value-of select="'ALTER TABLE value_list_values ENABLE TRIGGER ALL;'"/>
		</xsl:result-document>
	</xsl:template>
	
	<xsl:template match="//OpenInfRA:value_list">
		<xsl:variable name="Id" select="concat($apos,OpenInfRA:id,$apos)"/>
		<xsl:variable name="name">
			<xsl:for-each select="OpenInfRA:name/gmd:PT_FreeText/gmd:textGroup/@xlink:href">
				<xsl:if test="position() = 1">
					<xsl:variable name="sub" select="substring-after(.,'uuid_')"/>
					<xsl:value-of select="concat($apos,$sub,$apos)"/> 
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="description">
			<xsl:choose>
				<xsl:when test="OpenInfRA:description">
					<xsl:for-each select="OpenInfRA:description/gmd:PT_FreeText/gmd:textGroup/@xlink:href">
						<xsl:if test="position() = 1">
							<xsl:variable name="sub" select="substring-after(.,'uuid_')"/>
							<xsl:value-of select="concat($apos,$sub,$apos)"/>  
						</xsl:if>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="'NULL'"/>	
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="concat('INSERT INTO &quot;value_list&quot; VALUES (' ,$Id, ', ' ,$name, ', ' , $description, ');')"/>
		<xsl:text>&#10;</xsl:text>
	</xsl:template>
	
	<xsl:template match="//OpenInfRA:value_list_value">
		<xsl:variable name="Id" select="concat($apos,OpenInfRA:id,$apos)"/>
		<xsl:variable name="name">
			<xsl:for-each select="OpenInfRA:name/gmd:PT_FreeText/gmd:textGroup/@xlink:href">
				<xsl:if test="position() = 1">
					<xsl:variable name="sub" select="substring-after(.,'uuid_')"/>
					<xsl:value-of select="concat($apos,$sub,$apos)"/> 
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="description">
			<xsl:choose>
				<xsl:when test="OpenInfRA:description">
					<xsl:for-each select="OpenInfRA:description/gmd:PT_FreeText/gmd:textGroup/@xlink:href">
						<xsl:if test="position() = 1">
							<xsl:variable name="sub" select="substring-after(.,'uuid_')"/>
							<xsl:value-of select="concat($apos,$sub,$apos)"/>  
						</xsl:if>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="'NULL'"/>	
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="vis" select="OpenInfRA:visibility"/>
		<xsl:variable name="sub">
			<xsl:choose>
				<xsl:when test="OpenInfRA:belongs_to_value_list/OpenInfRA:reference">
					<xsl:value-of select="substring-after(OpenInfRA:belongs_to_value_list/OpenInfRA:reference/@idref,'uuid_')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring-after(OpenInfRA:belongs_to_value_list/OpenInfRA:value_list/@id,'uuid_')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="vl" select="concat($apos,$sub,$apos)"/>
		<xsl:value-of select="concat('INSERT INTO &quot;value_list_values&quot; VALUES (' ,$Id, ', ' ,$name, ', ' , $description, ', ' ,$vis,', ',$vl,');')"/>
		<xsl:text>&#10;</xsl:text>
	</xsl:template>
	
	<xsl:template match="//OpenInfRA:value_list/OpenInfRA:rel_value_list">
		<xsl:variable name="Id" select="concat($apos,parent::*/OpenInfRA:id,$apos)"/>
		<xsl:variable name="sub">
			<xsl:choose>
				<xsl:when test="OpenInfRA:reference">
					<xsl:value-of select="substring-after(OpenInfRA:reference/@idref,'uuid_')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring-after(OpenInfRA:value_list/@id,'uuid_')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="vl2" select="concat($apos,$sub,$apos)"/>
		<xsl:variable name="sub2">
			<xsl:choose>
				<xsl:when test="OpenInfRA:SKOS_relationship/OpenInfRA:reference">
					<xsl:value-of select="substring-after(OpenInfRA:SKOS_relationship/OpenInfRA:reference/@idref,'uuid_')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring-after(OpenInfRA:SKOS_relationship/OpenInfRA:value_list_value/@id,'uuid_')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="SKOS" select="concat($apos,$sub2,$apos)"/>
		<xsl:variable name="rel_id" select="OpenInfRA:id"/>
		<xsl:value-of select="concat('INSERT INTO &quot;value_list_x_value_list&quot; VALUES (',$apos,$rel_id,$apos ,', ' ,$Id, ', ' ,$vl2, ', ' , $SKOS, ');')"/>
		<xsl:text>&#10;</xsl:text>
	</xsl:template>
	
	<xsl:template match="//OpenInfRA:value_list_value/OpenInfRA:rel_value_list_value">
		<xsl:variable name="Id" select="concat($apos,parent::*/OpenInfRA:id,$apos)"/>
		<xsl:variable name="sub">
			<xsl:choose>
				<xsl:when test="OpenInfRA:reference">
					<xsl:value-of select="substring-after(OpenInfRA:reference/@idref,'uuid_')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring-after(OpenInfRA:value_list_value/@id,'uuid_')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="vl2" select="concat($apos,$sub,$apos)"/>
		<xsl:variable name="sub2">
			<xsl:choose>
				<xsl:when test="OpenInfRA:SKOS_relationship/OpenInfRA:reference">
					<xsl:value-of select="substring-after(OpenInfRA:SKOS_relationship/OpenInfRA:reference/@idref,'uuid_')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring-after(OpenInfRA:SKOS_relationship/OpenInfRA:value_list_value/@id,'uuid_')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="SKOS" select="concat($apos,$sub2,$apos)"/>
		<xsl:variable name="rel_id" select="OpenInfRA:id"/>
		<xsl:value-of select="concat('INSERT INTO &quot;value_list_values_x_value_list_values&quot; VALUES (',$apos,$rel_id,$apos ,', ' ,$Id, ', ' ,$vl2, ', ' , $SKOS, ');')"/>
		<xsl:text>&#10;</xsl:text>
	</xsl:template>

</xsl:stylesheet>
