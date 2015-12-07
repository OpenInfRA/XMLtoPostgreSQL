<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:math="/java.lang.Math" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:fn="http://www.w3.org/2004/10/xpath-functions" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="OpenInfRA">
	<xsl:strip-space elements="*"/>
	<!-- Generieren der Zugriffsschlüssel Elemente -->
	<xsl:key name="LCS_by_free_text_id" match="localized_character_string" use="pt_free_text_id"/>
	<xsl:key name="value_list_values_value_list_values_by_value_list_values_1" match="value_list_values_x005F_x_value_list_values" use="value_list_values_1"/>
	<xsl:key name="value_list_value_list_by_value_list_1" match="value_list_x005F_x_value_list" use="value_list_1"/>
	<xsl:template match="/*">
		<xsl:result-document method="xml" href="Ergebnis_XML/value_lists.xml" encoding="UTF-8" indent="yes">
			<!-- Erzeugen des value_listndokumentes -->
			<xsl:element name="lists">
				<!-- Wurzelelement generieren -->
				<xsl:namespace name="xlink" select="'http://www.w3.org/1999/xlink'"/>
				<xsl:namespace name="gmd" select="'http://www.isotc211.org/2005/gmd'"/>
				<xsl:namespace name="xsi" select="'http://www.w3.org/2001/XMLSchema-instance'"/>
				<xsl:attribute name="xsi:schemaLocation" select="'OpenInfRA ../../XSD/OpenInfRA_xsd_v12.xsd'" namespace="http://www.w3.org/2001/XMLSchema-instance"/>
				<xsl:element name="value_lists">
					<xsl:apply-templates select="value_list"/>
					<!-- Template zum Erzeugen der value_list aufrufen -->
				</xsl:element>
				<xsl:element name="value_list_values">
					<xsl:apply-templates select="value_list_values"/>
					<!-- Template zum Erzeugen der value_list_values aufrufen -->
				</xsl:element>
			</xsl:element>
		</xsl:result-document>
	</xsl:template>
	<!-- value_list_values erzeugen (Generierung analog zu den Elementen im trafo_Instanzdokument.xslt) -->
	<xsl:template match="value_list_values">
		<xsl:variable name="id" select="id"/>
		<xsl:element name="value_list_value">
			<xsl:attribute name="id">
				<xsl:value-of select="concat('uuid_',id)"/>
			</xsl:attribute>
			<xsl:element name="id">
				<xsl:value-of select="id"/>
			</xsl:element>
			<xsl:element name="name">
				<xsl:element name="gmd:PT_FreeText" namespace="http://www.isotc211.org/2005/gmd">
					<xsl:variable name="name" select="name"/>
					<xsl:for-each select="key('LCS_by_free_text_id',$name)">
						<xsl:element name="gmd:textGroup" namespace="http://www.isotc211.org/2005/gmd">
							<xsl:attribute name="xlink:href" namespace="http://www.w3.org/1999/xlink">
								<xsl:value-of select="concat('locale_',pt_locale_id,'.xml#uuid_',pt_free_text_id)"/>
							</xsl:attribute>
						</xsl:element>
					</xsl:for-each>
				</xsl:element>
			</xsl:element>
			<xsl:if test="description">
				<xsl:element name="description">
					<xsl:element name="gmd:PT_FreeText" namespace="http://www.isotc211.org/2005/gmd">
						<xsl:variable name="descr" select="description"/>
						<xsl:for-each select="key('LCS_by_free_text_id',$descr)">
							<xsl:element name="gmd:textGroup" namespace="http://www.isotc211.org/2005/gmd">
								<xsl:attribute name="xlink:href" namespace="http://www.w3.org/1999/xlink">
									<xsl:value-of select="concat('locale_',pt_locale_id,'.xml#uuid_',pt_free_text_id)"/>
								</xsl:attribute>
							</xsl:element>
						</xsl:for-each>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<xsl:element name="visibility">
				<xsl:value-of select="visibility"/>
			</xsl:element>
			<xsl:element name="belongs_to_value_list">
				<xsl:element name="reference">
					<xsl:attribute name="idref">
						<xsl:value-of select="concat('uuid_',belongs_to_value_list)"/>
					</xsl:attribute>
				</xsl:element>
			</xsl:element>
			<xsl:for-each select="key('value_list_values_value_list_values_by_value_list_values_1',$id)">
				<xsl:element name="rel_value_list_value">
					<xsl:element name="id">
						<xsl:value-of select="id"/>
					</xsl:element>
					<xsl:element name="reference">
						<xsl:attribute name="idref">
							<xsl:value-of select="concat('uuid_',value_list_values_2)"/>
						</xsl:attribute>
					</xsl:element>
					<xsl:element name="SKOS_relationship">
						<xsl:element name="reference">
							<xsl:attribute name="idref">
								<xsl:value-of select="concat('uuid_',relationship)"/>
							</xsl:attribute>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>
	<!-- value_list erzeugen (Generierung analog zu den Elementen im trafo_Instanzdokument.xslt) -->
	<xsl:template match="value_list">
		<xsl:variable name="id" select="id"/>
		<xsl:element name="value_list">
			<xsl:attribute name="id">
				<xsl:value-of select="concat('uuid_',id)"/>
			</xsl:attribute>
			<xsl:element name="id">
				<xsl:value-of select="id"/>
			</xsl:element>
			<xsl:element name="name">
				<xsl:element name="gmd:PT_FreeText" namespace="http://www.isotc211.org/2005/gmd">
					<xsl:variable name="name" select="name"/>
					<xsl:for-each select="key('LCS_by_free_text_id',$name)">
						<xsl:element name="gmd:textGroup" namespace="http://www.isotc211.org/2005/gmd">
							<xsl:attribute name="xlink:href" namespace="http://www.w3.org/1999/xlink">
								<xsl:value-of select="concat('locale_',pt_locale_id,'.xml#uuid_',pt_free_text_id)"/>
							</xsl:attribute>
						</xsl:element>
					</xsl:for-each>
				</xsl:element>
			</xsl:element>
			<xsl:if test="description">
				<xsl:element name="description">
					<xsl:element name="gmd:PT_FreeText" namespace="http://www.isotc211.org/2005/gmd">
						<xsl:variable name="descr" select="description"/>
						<xsl:for-each select="key('LCS_by_free_text_id',$descr)">
							<xsl:element name="gmd:textGroup" namespace="http://www.isotc211.org/2005/gmd">
								<xsl:attribute name="xlink:href" namespace="http://www.w3.org/1999/xlink">
									<xsl:value-of select="concat('locale_',pt_locale_id,'.xml#uuid_',pt_free_text_id)"/>
								</xsl:attribute>
							</xsl:element>
						</xsl:for-each>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<xsl:for-each select="key('value_list_value_list_by_value_list_1',$id)">
				<xsl:element name="rel_value_list">
					<xsl:element name="id">
						<xsl:value-of select="id"/>
					</xsl:element>
					<xsl:element name="reference">
						<xsl:attribute name="idref">
							<xsl:value-of select="concat('uuid_',value_list_2)"/>
						</xsl:attribute>
					</xsl:element>
					<xsl:element name="SKOS_relationship">
						<xsl:element name="reference">
							<xsl:attribute name="idref">
								<xsl:value-of select="concat('uuid_',relationship)"/>
							</xsl:attribute>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
