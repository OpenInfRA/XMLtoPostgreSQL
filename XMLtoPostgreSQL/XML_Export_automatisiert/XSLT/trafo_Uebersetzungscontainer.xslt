<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:math="/java.lang.Math" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:fn="http://www.w3.org/2004/10/xpath-functions" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xs="http://www.w3.org/2001/XMLSchema">
	<xsl:strip-space elements="*"/>
	
	<!-- Generieren der Zugriffsschlüssel Elemente -->	
	<xsl:key name="Locale_by_id" match="pt_locale" use="id" /> 
	<xsl:key name="country_code_by_id" match="country_code" use="id" /> 
	<xsl:key name="language_code_by_id" match="language_code" use="id" /> 
	<xsl:key name="character_code_by_id" match="character_code" use="id" /> 
	<xsl:key name="LCS_by_locale_id" match="localized_character_string" use="pt_locale_id" /> 

	<xsl:template match="/*">
		<xsl:for-each select="key('Locale_by_id',localized_character_string/pt_locale_id)"> <!-- nachfolgende Anweisungen für alle verwendeten Sprachumgebungen durchführen -->
				<!-- ids an Variablen übergeben -->
				<xsl:variable name="id" select="id"/>
				<xsl:variable name="L_id" select="country_code_id"/>
				<xsl:variable name="Z_id" select="character_code_id"/>
				<xsl:variable name="S_id" select="language_code_id"/>
				
				<!-- Sprachcode, Ländercode und character_code an Variablen übergeben -->
				<xsl:variable name="L">
					<xsl:for-each select="key('country_code_by_id',$L_id)">
							<xsl:value-of select="country_code"/>
					</xsl:for-each>
				</xsl:variable>
				<xsl:variable name="S">
					<xsl:for-each select="key('language_code_by_id',$S_id)">
							<xsl:value-of select="language_code"/>
					</xsl:for-each>
				</xsl:variable>
				<xsl:variable name="Z">
					<xsl:for-each select="key('character_code_by_id',$Z_id)">
							<xsl:value-of select="character_code"/>
					</xsl:for-each>
				</xsl:variable>
			
				<!-- Datei erzeugen und füllen -->
				<xsl:result-document method="xml" href="Ergebnis_XML/locale_{id}.xml" encoding="{$Z}" indent="yes"> <!-- Dateinamen aus Locale id generieren und angeben der entsprechenden character_code der Sprachumgebung -->
					<xsl:element name="gmd:PT_LocaleContainer" namespace="http://www.isotc211.org/2005/gmd"> <!-- PT_LocaleContainer Element erzeugen -->
						<xsl:namespace name="xlink" select="'http://www.w3.org/1999/xlink'"/>
						<xsl:namespace name="gmd" select="'http://www.isotc211.org/2005/gmd'"/>
						<xsl:namespace name="gco" select="'http://www.isotc211.org/2005/gco'"/>
						<xsl:namespace name="xsi" select="'http://www.w3.org/2001/XMLSchema-instance'"/>
						<xsl:attribute name="xsi:schemaLocation" select="'OpenInfRA ../../XSD/OpenInfRA_xsd_v12.xsd'" namespace="http://www.w3.org/2001/XMLSchema-instance"/>
						<xsl:element name="gmd:description" namespace="http://www.isotc211.org/2005/gmd"> <!-- description Element erzeugen -->
							<xsl:element name="gco:CharacterString" namespace="http://www.isotc211.org/2005/gco">
								<xsl:value-of select="concat('Freetext --- Country: ',$L,'  Language: ',$S,' CharacterSetCode: ',$Z)"/>
							</xsl:element>
						</xsl:element>
						<xsl:element name="gmd:locale" namespace="http://www.isotc211.org/2005/gmd"> <!-- locale Element erzeugen -->
							<xsl:element name="gmd:PT_Locale" namespace="http://www.isotc211.org/2005/gmd">
								<xsl:attribute name="id" select="concat('uuid_',id)"/>
								<xsl:element name="gmd:languageCode" namespace="http://www.isotc211.org/2005/gmd">
									<xsl:element name="gmd:LanguageCode" namespace="http://www.isotc211.org/2005/gmd">
										<xsl:attribute name="codeList" select="'../Codeliste/codelist.xml#LanguageCode'"/>
										<xsl:attribute name="codeListValue" select="$S"/>
										<xsl:value-of select="$S"/>
									</xsl:element>
								</xsl:element>
								<xsl:if test="country_code_id"> <!-- wenn ein Ländercode vorhanden ist, wird das country Element generiert -->
									<xsl:element name="gmd:country" namespace="http://www.isotc211.org/2005/gmd">
										<xsl:element name="gmd:Country" namespace="http://www.isotc211.org/2005/gmd">
											<xsl:attribute name="codeList" select="'../Codeliste/codelist.xml#CountryCode'"/>
											<xsl:attribute name="codeListValue" select="$L"/>
											<xsl:value-of select="$L"/>
										</xsl:element>
									</xsl:element>
								</xsl:if>
								<xsl:element name="gmd:characterEncoding" namespace="http://www.isotc211.org/2005/gmd"> <!-- characterEncoding Element erzeugen -->
									<xsl:element name="gmd:MD_CharacterSetCode" namespace="http://www.isotc211.org/2005/gmd">
										<xsl:attribute name="codeList" select="'../Codeliste/codelist.xml#MD_CharacterSetCode'"/>
										<xsl:attribute name="codeListValue" select="$Z"/>
										<xsl:value-of select="$Z"/>
									</xsl:element>
								</xsl:element>
							</xsl:element>
						</xsl:element>
						<xsl:element name="gmd:date" namespace="http://www.isotc211.org/2005/gmd">  <!-- date Element erzeugen -->
							<xsl:element name="gmd:CI_Date" namespace="http://www.isotc211.org/2005/gmd">
								<xsl:element name="gmd:date" namespace="http://www.isotc211.org/2005/gmd">
									<xsl:element name="gco:Date" namespace="http://www.isotc211.org/2005/gco">
										<xsl:value-of select="current-date()"/>
									</xsl:element>
								</xsl:element>
								<xsl:element name="gmd:dateType" namespace="http://www.isotc211.org/2005/gmd">
									<xsl:element name="gmd:CI_DateTypeCode" namespace="http://www.isotc211.org/2005/gmd">
										<xsl:attribute name="codeList" select="'../Codeliste/codelist.xml#CI_DateTypeCode'"/>
										<xsl:attribute name="codeListValue" select="'creation'"/>									
										<xsl:value-of select="'creation'"/>
									</xsl:element>
								</xsl:element>
							</xsl:element>
						</xsl:element>
						<xsl:element name="gmd:responsibleParty" namespace="http://www.isotc211.org/2005/gmd">  <!-- responsibleParty Element erzeugen -->
							<xsl:element name="gmd:CI_ResponsibleParty" namespace="http://www.isotc211.org/2005/gmd">
								<xsl:element name="gmd:role" namespace="http://www.isotc211.org/2005/gmd">
									<xsl:element name="gmd:CI_RoleCode" namespace="http://www.isotc211.org/2005/gmd">
										<xsl:attribute name="codeList" select="'../Codeliste/codelist.xml#CI_RoleCode'"/>
										<xsl:attribute name="codeListValue" select="'author'"/>									
										<xsl:value-of select="'author'"/>
									</xsl:element>
								</xsl:element>
							</xsl:element>
						</xsl:element>
						<xsl:for-each select="key('LCS_by_locale_id',$id)"> <!-- für alle lokalisierten Zeichenketten der Sprachumgebung wird ein localisedString Element erzeugt -->
							<xsl:element name="gmd:localisedString" namespace="http://www.isotc211.org/2005/gmd">
								<xsl:element name="gmd:LocalisedCharacterString" namespace="http://www.isotc211.org/2005/gmd">
									<xsl:attribute name="id" select="concat('uuid_',pt_free_text_id)"/>
									<xsl:attribute name="locale" select="concat('#uuid_',pt_locale_id)"/>
									<xsl:value-of select="normalize-space(free_text)"/>
								</xsl:element>
							</xsl:element>
					</xsl:for-each>
					</xsl:element>
				</xsl:result-document> 
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>