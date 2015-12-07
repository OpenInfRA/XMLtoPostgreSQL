<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:math="/java.lang.Math" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:fn="http://www.w3.org/2004/10/xpath-functions" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:OpenInfRA="OpenInfRA" xmlns:uuid="java:java.util.UUID">
	<xsl:output method="text" indent="yes"/>
	<xsl:variable name="apos" select='"&apos;"'/>
	<xsl:variable name="apos2" select='"&apos;&apos;"'/>
	<xsl:param name="spath" select="spath"/>

	<xsl:template match="/*">
		<xsl:variable name="id" select="substring-after(gmd:locale/gmd:PT_Locale/@id,'uuid_')"/>
		<xsl:result-document method="text" href="SQL_Script/Import_locale_{$id}.sql">
			<xsl:value-of select="concat('SET search_path TO &quot;',$spath,'&quot;, constraints, public;')"/>
			<xsl:text>&#10;</xsl:text>
			<xsl:value-of select="'SET CLIENT_ENCODING TO &quot;UTF8&quot; ;'"/>
			<xsl:text>&#10;</xsl:text>
			<xsl:apply-templates select="gmd:locale/gmd:PT_Locale"/>
			<xsl:apply-templates select="gmd:localisedString/gmd:LocalisedCharacterString"/>
		</xsl:result-document>
	</xsl:template>

	<xsl:template match="gmd:locale/gmd:PT_Locale">
		<xsl:variable name="sub" select="substring-after(@id,'uuid_')"/>
		<xsl:variable name="Id" select="concat($apos,$sub,$apos)"/>
		<xsl:variable name="Z" select="concat($apos,gmd:characterEncoding/gmd:MD_CharacterSetCode,$apos)"/>
		<!-- The uuid of the character encoding is randomly generated. I don't know why. But it's wrong since the uuid of the character encoding
             must be globally known by all translation containers. -->
		<xsl:variable name="Zuuid" select="concat($apos,uuid:randomUUID(),$apos)"/>
		<xsl:variable name="GLOBALuuid" select="concat($apos,'6a61ffb2-bc80-445e-a971-cf45ebe62073',$apos)"/>
		
		<!-- It's important to insert the the character_code only when it doesn't exists. Otherwise, the
             transaction will be cancelled. Therefore use the globally known uuid. -->
		<xsl:choose>
			<xsl:when test="gmd:characterEncoding/gmd:MD_CharacterSetCode = 'UTF8'">
				<xsl:value-of select="concat('INSERT INTO &quot;character_code&quot; (&quot;id&quot;, &quot;character_code&quot;) SELECT ' ,$GLOBALuuid, ', ' ,$Z,' WHERE NOT EXISTS ( SELECT &quot;id&quot;,&quot;character_code&quot; FROM character_code WHERE id = ',$GLOBALuuid,' AND character_code = ',$Z,' );')"/>		
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('INSERT INTO &quot;character_code&quot; VALUES (' ,$Zuuid, ', ' ,$Z,');')"/>
			</xsl:otherwise>
		</xsl:choose>
	
		<xsl:text>&#10;</xsl:text>
		<xsl:variable name="Suuid" select="concat($apos,uuid:randomUUID(),$apos)"/>
		<xsl:variable name="S" select="concat($apos,gmd:languageCode/gmd:LanguageCode,$apos)"/>
		<xsl:value-of select="concat('INSERT INTO &quot;language_code&quot; VALUES (' ,$Suuid, ', ' ,$S,');')"/>
		<xsl:text>&#10;</xsl:text>
		<xsl:variable name="Luuid" >
			<xsl:choose>
				<!-- xsl:when test="gmd:languageCode/gmd:LanguageCode"-->
				<xsl:when test="gmd:country/gmd:Country != 'xx'">
					<xsl:value-of select="concat($apos,uuid:randomUUID(),$apos)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="'NULL'"/>	
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="gmd:country/gmd:Country != 'xx'">
			<xsl:variable name="L" select="concat($apos,gmd:country/gmd:Country,$apos)"/>
			<xsl:value-of select="concat('INSERT INTO &quot;country_code&quot; VALUES (' ,$Luuid, ', ' ,$L,');')"/>
			<xsl:text>&#10;</xsl:text>
		</xsl:if>
		<!-- It's important to insert the the character_code only when it doesn't exists. Otherwise, the
             transaction will be cancelled. Therefore use the globally known uuid. -->
		<xsl:choose>
			<xsl:when test="gmd:characterEncoding/gmd:MD_CharacterSetCode = 'UTF8'">
				<xsl:value-of select="concat('INSERT INTO &quot;pt_locale&quot; VALUES (' ,$Id, ', ' ,$Suuid, ', ' , $Luuid, ', ' ,$GLOBALuuid,');')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('INSERT INTO &quot;pt_locale&quot; VALUES (' ,$Id, ', ' ,$Suuid, ', ' , $Luuid, ', ' ,$Zuuid,');')"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>&#10;</xsl:text>
	</xsl:template>

	<xsl:template match="gmd:localisedString/gmd:LocalisedCharacterString">
		<xsl:variable name="sub" select="substring-after(@id,'uuid_')"/>
		<xsl:variable name="Id" select="concat($apos,$sub,$apos)"/>
		<xsl:value-of select="concat('INSERT INTO pt_free_text (&quot;id&quot;) SELECT ',$Id,' WHERE NOT EXISTS ( SELECT &quot;id&quot; FROM pt_free_text WHERE id=',$Id,');')"/>
		<xsl:text>&#10;</xsl:text>
		<xsl:variable name="subLocale" select="substring-after(@locale,'uuid_')"/>
		<xsl:variable name="locale" select="concat($apos,$subLocale,$apos)"/>
		<xsl:variable name="text1">
			<xsl:choose>
				<xsl:when test="contains(., $apos)">
					<xsl:value-of select="replace(.,$apos,$apos2)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="text" select="concat($apos,$text1,$apos)"/>
		<xsl:value-of select="concat('INSERT INTO &quot;localized_character_string&quot; VALUES (' ,$Id, ', ' ,$locale, ', ' , $text, ');')"/>
		<xsl:text>&#10;</xsl:text>
	</xsl:template>

</xsl:stylesheet>
