<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:math="/java.lang.Math" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:fn="http://www.w3.org/2004/10/xpath-functions" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="OpenInfRA" xmlns:gml="http://www.opengis.net/gml">
	<xsl:output method="xml" indent="yes" encoding="UTF-8" standalone="no" />
	<xsl:strip-space elements="*"/>
	<xsl:variable name="geom" select="document('../Datenbank_Exportdatei/DB_Export_Geometry.xml')"/>
	<xsl:variable name="geomZ" select="document('../Datenbank_Exportdatei/DB_Export_GeometryZ.xml')"/>

    <!-- Generieren der Zugriffsschlüssel Elemente -->	
    <xsl:key name="LCS_by_free_text_id" match="localized_character_string" use="pt_free_text_id" /> 
	<xsl:key name="attribute_type_attribute_type_group_by_attribute_type_id" match="attribute_type_group" use="attribute_type_id" /> 
	<xsl:key name="attribute_type_attribute_type_group_by_attribute_type_group" match="attribute_type_group" use="attribute_type_group" /> 
	<xsl:key name="attribute_type_attribute_type_by_attribute_type1" match="attribute_type_x005F_x_attribute_type" use="attribute_type_1" /> 
	<xsl:key name="multiplicity_by_id" match="multiplicity" use="id" /> 
	<xsl:key name="topic_instance_topic_instance_by_topic_instance_1" match="topic_instance_x005F_x_topic_instance" use="topic_instance_1" /> 
	<xsl:key name="Geometry_by_id" match="geometry" use="@id" />
	<xsl:key name="GeometryZ_by_id" match="geometryz" use="@id" />
	
	<xsl:template match="/*">
		<xsl:result-document method="xml" href="Ergebnis_XML/OpenInfRA_XML.xml" encoding="UTF-8" indent="yes">   <!--Generieren der Zieldatei OpenInfR_XML.xml -->
			<xsl:element name="dataset" >  <!-- Wurzelelement -->
				<xsl:namespace name="xlink" select="'http://www.w3.org/1999/xlink'"/> <!-- namespace -->
				<xsl:namespace name="gmd" select="'http://www.isotc211.org/2005/gmd'"/>
				<xsl:namespace name="gml" select="'http://www.opengis.net/gml'"/> 
				<xsl:namespace name="xsi" select="'http://www.w3.org/2001/XMLSchema-instance'"/>
				<xsl:attribute name="xsi:schemaLocation" select="'OpenInfRA ../../XSD/OpenInfRA_xsd_v13.xsd'" namespace="http://www.w3.org/2001/XMLSchema-instance"/> <!-- Hinzufügen des relativen Speicherpfades der XSchema Datei -->
				<!-- Aufruf des Templates zum Erzeugen der attribute_typeen=================================== -->
				<xsl:apply-templates select="attribute_type"/>						
				<!-- Aufruf des Templates zum Erzeugen der attribute_type_groupn================================ -->
				<xsl:apply-templates select="attribute_type_group"/>	
				<!-- Aufruf des Templates zum Erzeugen der attribute_type_to_topic_characteristic=================== -->		    
				<xsl:apply-templates select="attribute_type_group_to_topic_characteristic"/>
				<!-- Aufruf des Templates zum Erzeugen der attribute_type_to_attribute_type_group=================== -->		    
				<xsl:apply-templates select="attribute_type_to_attribute_type_group"/>
				<!-- Aufruf des Templates zum Erzeugen der attribute_value=================================== -->	
				<xsl:apply-templates select="attribute_value_domain"/>
				<!-- Aufruf des Templates zum Erzeugen der attribute_value=================================== -->	
				<xsl:apply-templates select="attribute_value_value"/>
				<!-- Aufruf des Templates zum Erzeugen der attribute_value=================================== -->	
				<xsl:apply-templates select="attribute_value_geom"/>
				<!-- Aufruf des Templates zum Erzeugen der attribute_value=================================== -->	
				<xsl:apply-templates select="attribute_value_geomz"/>
				<!-- Aufruf des Templates zum Erzeugen der relationship_types================================ -->	
				<xsl:apply-templates select="relationship_type"/>
				<!-- Aufruf des Templates zum Erzeugen der relationship_type_to_topic_characteristic=============== -->	
				<xsl:apply-templates select="relationship_type_to_topic_characteristic"/>
				<!-- Aufruf des Templates zum Erzeugen der multiplicity====================================== -->	
				<xsl:apply-templates select="multiplicity"/>
				<!-- Aufruf des Templates zum Erzeugen der projects====================================== -->	
				<xsl:apply-templates select="project"/>
				<!-- Aufruf des Templates zum Erzeugen der Themen====================================== -->	
				<xsl:apply-templates select="topic_characteristic/topic[not(.=following::topic_characteristic/topic)]"/>
				<!-- Aufruf des Templates zum Erzeugen der topic_characteristic============================== -->
				<xsl:apply-templates select="topic_characteristic"/>
				<!-- Aufruf des Templates zum Erzeugen der topic_instance================================= -->
				<xsl:apply-templates select="topic_instance"/>
			</xsl:element>
		</xsl:result-document>
	</xsl:template>
	
	<!-- Erzeugen der attribute_typeen -->
	<xsl:template match="attribute_type">	<!-- Template wird nur für attribute_typeelemente ausgeführt -->
		<xsl:element name="attribute_type"> <!-- Erzeugen des Elements attribute_type -->
			<xsl:variable name="id_attribute_type" select="id"/>
			<xsl:attribute name="id"> <!-- Erzeugen des id Attributes -->
				<xsl:value-of select="concat('uuid_',id)"/>
			</xsl:attribute>
			<xsl:element name="id"> <!-- Erzeugen des id Elements -->
				<xsl:value-of select="id"/>
			</xsl:element>
			<xsl:element name="name"> <!-- Erzeugen des name Elements  -->
				<xsl:element name="gmd:PT_FreeText" namespace="http://www.isotc211.org/2005/gmd"> <!-- Erzeugen des PT_FreeText Elementes -->
					<xsl:variable name="name" select="name"/> <!-- Speichern des Wertes des name Elementes in einer Variable -->
					<xsl:for-each select="key('LCS_by_free_text_id',$name)"> <!-- nachfolgende Anweisungen für jedes LocalizedCharcterString Element durchführt, welches den entsprechenden Schlüssel (key) aufweist -->
							<xsl:element name="gmd:textGroup" namespace="http://www.isotc211.org/2005/gmd"> <!-- Erzeugen des textGroup Elements  -->
								<xsl:attribute name="xlink:href" namespace="http://www.w3.org/1999/xlink"> <!-- Hinzufügen des Xlink:href Attributs zum textGroup Elements  -->
									<xsl:value-of select="concat('locale_',pt_locale_id,'.xml#','uuid_',pt_free_text_id)"/> <!-- Erzeugen des attribute_values aus den Werten der PT_Locale id und der PT_FreeText id-->
								</xsl:attribute>
							</xsl:element>
					</xsl:for-each>
				</xsl:element>
			</xsl:element>
			<xsl:if test="description"> <!-- falls das jeweilige attribute_typeelement das Unterelement description aufweist, sollen die nachfolgenden Anweisungen durchgeführt werden -->
				<xsl:element name="description">  <!-- Erzeugen des description Elements  -->
					<xsl:element name="gmd:PT_FreeText" namespace="http://www.isotc211.org/2005/gmd"> <!-- Generieren des PT_FreeText Elements und aller zugehörigen Unterelemente analog zu den oben descriebenen PT_FreeText Elementen -->
						<xsl:variable name="descr" select="description"/>
						<xsl:for-each select="key('LCS_by_free_text_id',$descr)"> <!-- nachfolgende Anweisungen für jedes LocalizedCharcterString Element durchführt, welches den entsprechenden Schlüssel (key) aufweist -->
								<xsl:element name="gmd:textGroup" namespace="http://www.isotc211.org/2005/gmd">
									<xsl:attribute name="xlink:href" namespace="http://www.w3.org/1999/xlink">
										<xsl:value-of select="concat('locale_',pt_locale_id,'.xml#','uuid_',pt_free_text_id)"/> 
									</xsl:attribute>
								</xsl:element>
						</xsl:for-each>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<xsl:element name="data_type"> <!-- Erzeugen des data_type Elements  -->
				<xsl:attribute name="value_list_value"> <!-- Hinzufügen des value_list_value Attributs zum data_type Element -->
					<xsl:value-of select="concat('value_lists.xml#uuid_',data_type)"/> <!-- Erzeugen des attribute_values -->
				</xsl:attribute>
			</xsl:element>
			<xsl:if test="domain"> <!-- falls das jeweilige attribute_typeelement das Unterelement domain aufweist, sollen die nachfolgenden Anweisungen durchgeführt werden -->
				<xsl:element name="domain"> <!-- Erzeugen des domain Elements  -->
					<xsl:attribute name="value_list"> <!-- Hinzufügen des value_list_value Attributs zum domain Element -->
						<xsl:value-of select="concat('value_lists.xml#uuid_',domain)"/> <!-- Erzeugen des attribute_values -->
					</xsl:attribute>
				</xsl:element>
			</xsl:if>
			<xsl:if test="unit"> <!-- falls das jeweilige attribute_typeelement das Unterelement unit aufweist, sollen die nachfolgenden Anweisungen durchgeführt werden -->
				<xsl:element name="unit"> <!-- Erzeugen des unit Elements  -->
					<xsl:attribute name="value_list_value"> <!-- Hinzufügen des value_list_value Attributs zum unit Element -->
						<xsl:value-of select="concat('value_lists.xml#uuid_',unit)"/> <!-- Erzeugen des attribute_values -->
					</xsl:attribute>
				</xsl:element>
			</xsl:if>
			<xsl:for-each select="key('attribute_type_attribute_type_group_by_attribute_type_id',$id_attribute_type)"> <!-- nachfolgende Anweisungen werden für jedes attribute_type_group Element durchführt, welches den entsprechenden Schlüssel (key = attribute_type_id) aufweist -->
					<xsl:element name="rel_attribute_type_group"> <!-- Erzeugen des rel_attribute_type_group Elements  -->
						<xsl:element name="reference">
							<xsl:attribute name="idref"> <!-- Hinzufügen des idref Attributs zum rel_attribute_type_group Element -->
								<xsl:value-of select="concat('uuid_',attribute_type_group)"/> <!-- Erzeugen des attribute_values -->
							</xsl:attribute>
						</xsl:element>
					</xsl:element>
			</xsl:for-each>
			<xsl:for-each select="key('attribute_type_attribute_type_by_attribute_type1',$id_attribute_type)">  <!-- nachfolgende Anweisungen werden für jedes attribute_type_x005F_x_attribute_type Element durchführt, welches den entsprechenden Schlüssel (key = attribute_type_1) aufweist -->
					<xsl:element name="rel_attribute_type"> <!-- Erzeugen des rel_attribute_type Elements  -->
					<xsl:element name="id">
						<xsl:value-of select="id"/>
					</xsl:element>
						<xsl:element name="reference">
							<xsl:attribute name="idref"> <!-- Hinzufügen des idref Attributs zum rel_attribute_type Element -->
								<xsl:value-of select="concat('uuid_',attribute_type_2)"/> <!-- Erzeugen des attribute_values -->
							</xsl:attribute>
						</xsl:element>
						<xsl:element name="SKOS_relationship">
							<xsl:attribute name="value_list_value"> <!-- Hinzufügen des SKOS_relationship Attributs zum rel_attribute_type Element -->
								<xsl:value-of select="concat('value_lists.xml#uuid_',relationship)"/> <!-- Erzeugen des attribute_values zum Verweis auf das value_listsdokument-->
							</xsl:attribute>
						</xsl:element>
					</xsl:element>
			</xsl:for-each>
		</xsl:element>	
	</xsl:template>
	
	<!-- Erzeugen der attribute_type_groupn -->
	<xsl:template match="attribute_type_group"> <!-- nachfolgende Anweisungen für jedes attribute_type_groupn Element der Klasse attribute_type_group Element, jedoch nur einmal für jede attribute_type_group -->
		<xsl:element name="attribute_type_group"> <!-- Erzeugen des Elements attribute_type_group -->
			<xsl:variable name="id" select="id"/> <!-- Schreiben der id in eine Variable -->
			<xsl:attribute name="id"> <!-- Hinzufügen des Attributes id -->
				<xsl:value-of select="concat('uuid_',$id)"/> <!-- Erzeugen des attribute_values -->
			</xsl:attribute>	
			<xsl:element name="id"> <!-- Erzeugen des id Elements -->
				<xsl:value-of select="id"/>
			</xsl:element>
			<xsl:element name="name"> <!-- Erzeugen des name Elements  -->
				<xsl:element name="gmd:PT_FreeText" namespace="http://www.isotc211.org/2005/gmd"> <!-- Erzeugen des PT_FreeText Elementes -->
					<xsl:variable name="name" select="name"/> <!-- Speichern des Wertes des name Elementes in einer Variable -->
					<xsl:for-each select="key('LCS_by_free_text_id',$name)"> <!-- nachfolgende Anweisungen für jedes LocalizedCharcterString Element durchführt, welches den entsprechenden Schlüssel (key) aufweist -->
							<xsl:element name="gmd:textGroup" namespace="http://www.isotc211.org/2005/gmd"> <!-- Erzeugen des textGroup Elements  -->
								<xsl:attribute name="xlink:href" namespace="http://www.w3.org/1999/xlink"> <!-- Hinzufügen des Xlink:href Attributs zum textGroup Elements  -->
									<xsl:value-of select="concat('locale_',pt_locale_id,'.xml#','uuid_',pt_free_text_id)"/> <!-- Erzeugen des attribute_values aus den Werten der PT_Locale id und der PT_FreeText id-->
								</xsl:attribute>
							</xsl:element>
					</xsl:for-each>
				</xsl:element>
			</xsl:element>
			<xsl:if test="description">
				<xsl:element name="description"> <!-- Erzeugen des Elements description -->
					<xsl:attribute name="value_list_value"> <!-- Hinzufügen des Attributes value_list_value -->
						<xsl:value-of select="concat('value_lists.xml#uuid_',description)"/>
					</xsl:attribute>
				</xsl:element>
			</xsl:if>
			<xsl:if test="subgroup_of">
				<xsl:element name="subgroup_of">
					<xsl:element name="reference">
						<xsl:attribute name="idref">
							<xsl:value-of select="concat('uuid_',subgroup_of)"/> <!-- Erzeugen des attribute_values -->
						</xsl:attribute>
					</xsl:element>
				</xsl:element>			
			</xsl:if>
		</xsl:element>
	</xsl:template>
	
	<!-- analog zum attribute_type Element werden nachfolgend alle weiteren Elemente generiert -->
	
	<!-- Erzeugen der attribute_type_to_topic_characteristic -->
	<xsl:template match="attribute_type_group_to_topic_characteristic">
		<xsl:element name="attribute_type_group_to_topic_characteristic">
			<xsl:variable name="id_attribute_type" select="id"/>
			<xsl:attribute name="id"> <!-- Erzeugen des id Attributes -->
				<xsl:value-of select="concat('uuid_',id)"/>
			</xsl:attribute>
			<xsl:element name="id"> <!-- Erzeugen des id Elements -->
				<xsl:value-of select="id"/>
			</xsl:element>
			<xsl:element name="multiplicity">
				<xsl:element name="reference">
					<xsl:attribute name="idref">
						<xsl:value-of select="concat('uuid_',multiplicity)"/> 
					</xsl:attribute>
				</xsl:element>
			</xsl:element>
			<xsl:if test="order">
				<xsl:element name="order">
					<xsl:value-of select="order"/>
				</xsl:element>
			</xsl:if>	
			<xsl:element name="rel_attribute_type_group">
				<xsl:element name="reference">
					<xsl:attribute name="idref">
						<xsl:value-of select="concat('uuid_',attribute_type_group_id)"/> <!-- Erzeugen des attribute_values -->
					</xsl:attribute>
				</xsl:element>
			</xsl:element>
			<xsl:element name="rel_topic_characteristic">
				<xsl:element name="reference">
					<xsl:attribute name="idref">
						<xsl:value-of select="concat('uuid_',topic_characteristic_id)"/> <!-- Erzeugen des attribute_values -->
					</xsl:attribute>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<!-- Erzeugen der attribute_type_to_attribute_type_group -->
	<xsl:template match="attribute_type_to_attribute_type_group">
		<xsl:element name="attribute_type_to_attribute_type_group">
			<xsl:variable name="id_attribute_type" select="id"/>
			<xsl:attribute name="id"> <!-- Erzeugen des id Attributes -->
				<xsl:value-of select="concat('uuid_',id)"/>
			</xsl:attribute>
			<xsl:element name="id"> <!-- Erzeugen des id Elements -->
				<xsl:value-of select="id"/>
			</xsl:element>
			<xsl:element name="multiplicity">
				<xsl:element name="reference">
					<xsl:attribute name="idref">
						<xsl:value-of select="concat('uuid_',multiplicity)"/> 
					</xsl:attribute>
				</xsl:element>
			</xsl:element>
			<xsl:if test="default_value">
				<xsl:element name="default_value">
				<xsl:attribute name="value_list_value">
					<xsl:value-of select="concat('value_lists.xml#uuid_',default_value)"/> <!-- Erzeugen des attribute_values -->
				</xsl:attribute>
			</xsl:element>
			</xsl:if>
			<xsl:if test="order">
				<xsl:element name="order">
					<xsl:value-of select="order"/>
				</xsl:element>
			</xsl:if>
			<xsl:element name="rel_attribute_type">
				<xsl:element name="reference">
					<xsl:attribute name="idref">
						<xsl:value-of select="concat('uuid_',attribute_type_id)"/> <!-- Erzeugen des attribute_values -->
					</xsl:attribute>
				</xsl:element>
			</xsl:element>	
			<xsl:element name="rel_attribute_type_group">
				<xsl:element name="reference">
					<xsl:attribute name="idref">
						<xsl:value-of select="concat('uuid_',attribute_type_group_id)"/> <!-- Erzeugen des attribute_values -->
					</xsl:attribute>
				</xsl:element>
			</xsl:element>
			<xsl:element name="rel_attribute_type_group_to_topic_characteristic">
				<xsl:element name="reference">
					<xsl:attribute name="idref">
						<xsl:value-of select="concat('uuid_',attribute_type_group_to_topic_characteristic_id)"/> <!-- Erzeugen des attribute_values -->
					</xsl:attribute>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<!-- Erzeugen der attribute_value -->
	<xsl:template match="attribute_value_domain">
		<xsl:element name="attribute_value">
			<xsl:attribute name="id">
				<xsl:value-of select="concat('uuid_',id)"/> <!-- Erzeugen des attribute_values -->
			</xsl:attribute>
			<xsl:element name="domain">
				<xsl:attribute name="value_list_value">
					<xsl:value-of select="concat('value_lists.xml#uuid_',domain)"/> <!-- Erzeugen des attribute_values -->
				</xsl:attribute>
			</xsl:element>
			<xsl:element name="rel_attribute_type_to_attribute_type_group">
				<xsl:element name="reference">
					<xsl:attribute name="idref">
						<xsl:value-of select="concat('uuid_',attribute_type_to_attribute_type_group_id)"/> <!-- Erzeugen des attribute_values -->
					</xsl:attribute>
				</xsl:element>
			</xsl:element>
			<xsl:element name="rel_topic_instance">
				<xsl:element name="reference">
					<xsl:attribute name="idref">
						<xsl:value-of select="concat('uuid_',topic_instance_id)"/> <!-- Erzeugen des attribute_values -->
					</xsl:attribute>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="attribute_value_value">
		<xsl:element name="attribute_value">
			<xsl:attribute name="id">
				<xsl:value-of select="concat('uuid_',id)"/> <!-- Erzeugen des attribute_values -->
			</xsl:attribute>
			<xsl:element name="value">
				<xsl:element name="gmd:PT_FreeText" namespace="http://www.isotc211.org/2005/gmd">
					<xsl:variable name="value" select="value"/>
					<xsl:for-each select="key('LCS_by_free_text_id',$value)"> 
						<xsl:element name="gmd:textGroup" namespace="http://www.isotc211.org/2005/gmd">
							<xsl:attribute name="xlink:href" namespace="http://www.w3.org/1999/xlink">
								<xsl:value-of select="concat('locale_',pt_locale_id,'.xml#','uuid_',pt_free_text_id)"/>
							</xsl:attribute>
						</xsl:element>
					</xsl:for-each>
				</xsl:element>
			</xsl:element>
			<xsl:element name="rel_attribute_type_to_attribute_type_group">
				<xsl:element name="reference">
					<xsl:attribute name="idref">
						<xsl:value-of select="concat('uuid_',attribute_type_to_attribute_type_group_id)"/> <!-- Erzeugen des attribute_values -->
					</xsl:attribute>
				</xsl:element>
			</xsl:element>
			<xsl:element name="rel_topic_instance">
				<xsl:element name="reference">
					<xsl:attribute name="idref">
						<xsl:value-of select="concat('uuid_',topic_instance_id)"/> <!-- Erzeugen des attribute_values -->
					</xsl:attribute>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
		<xsl:template match="attribute_value_geom">
		<xsl:element name="attribute_value">
			<xsl:attribute name="id">
				<xsl:value-of select="concat('uuid_',id)"/> <!-- Erzeugen des attribute_values -->
			</xsl:attribute>
			<xsl:variable name="geom_id" select="id"/>
			<xsl:element name="geometry">
				<xsl:for-each select="$geom">
					<xsl:copy-of select="key('Geometry_by_id',$geom_id)/*"/>
				</xsl:for-each>
			</xsl:element>
			<xsl:element name="rel_attribute_type_to_attribute_type_group">
				<xsl:element name="reference">
					<xsl:attribute name="idref">
						<xsl:value-of select="concat('uuid_',attribute_type_to_attribute_type_group_id)"/> <!-- Erzeugen des attribute_values -->
					</xsl:attribute>
				</xsl:element>
			</xsl:element>
			<xsl:element name="rel_topic_instance">
				<xsl:element name="reference">
					<xsl:attribute name="idref">
						<xsl:value-of select="concat('uuid_',topic_instance_id)"/> <!-- Erzeugen des attribute_values -->
					</xsl:attribute>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="attribute_value_geomz">
		<xsl:element name="attribute_value">
			<xsl:attribute name="id">
				<xsl:value-of select="concat('uuid_',id)"/> <!-- Erzeugen des attribute_values -->
			</xsl:attribute>
			<xsl:variable name="geom_id" select="id"/>
			<xsl:element name="geometryZ">
				<xsl:for-each select="$geomZ">
					<xsl:copy-of select="key('GeometryZ_by_id',$geom_id)/*"/>
				</xsl:for-each>
			</xsl:element>
			<xsl:element name="rel_attribute_type_to_attribute_type_group">
				<xsl:element name="reference">
					<xsl:attribute name="idref">
						<xsl:value-of select="concat('uuid_',attribute_type_to_attribute_type_group_id)"/> <!-- Erzeugen des attribute_values -->
					</xsl:attribute>
				</xsl:element>
			</xsl:element>
			<xsl:element name="rel_topic_instance">
				<xsl:element name="reference">
					<xsl:attribute name="idref">
						<xsl:value-of select="concat('uuid_',topic_instance_id)"/> <!-- Erzeugen des attribute_values -->
					</xsl:attribute>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>
		
	<!-- Erzeugen der relationship_types -->
	<xsl:template match="relationship_type">
		<xsl:element name="relationship_type">
			<xsl:attribute name="id">
				<xsl:value-of select="concat('uuid_',id)"/> <!-- Erzeugen des attribute_values -->
			</xsl:attribute>
			<xsl:element name="id">
				<xsl:value-of select="id"/>
			</xsl:element>
			<xsl:element name="reference_to">
				<xsl:attribute name="value_list_value">
					<xsl:value-of select="concat('value_lists.xml#uuid_',reference_to)"/> <!-- Erzeugen des attribute_values -->
				</xsl:attribute>
			</xsl:element>
			<xsl:element name="description">
				<xsl:attribute name="value_list_value">
					<xsl:value-of select="concat('value_lists.xml#uuid_',description)"/> <!-- Erzeugen des attribute_values -->
				</xsl:attribute>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<!-- Erzeugen der relationship_type_to_topic_characteristic -->
	<xsl:template match="relationship_type_to_topic_characteristic">
		<xsl:element name="relationship_type_to_topic_characteristic">
			<xsl:attribute name="id">
				<xsl:value-of select="concat('uuid_',id)"/>
			</xsl:attribute>
			<xsl:element name="id">
				<xsl:value-of select="id"/>
			</xsl:element>
			<xsl:element name="multiplicity">
				<xsl:element name="reference">
					<xsl:attribute name="idref">
						<xsl:value-of select="concat('uuid_',multiplicity)"/> 
					</xsl:attribute>
				</xsl:element>
			</xsl:element>
			<xsl:element name="rel_relationship_type">
				<xsl:element name="reference">
					<xsl:attribute name="idref">
						<xsl:value-of select="concat('uuid_',relationship_type_id)"/> <!-- Erzeugen des attribute_values -->
					</xsl:attribute>
				</xsl:element>
			</xsl:element>
			<xsl:element name="rel_topic_characteristic">
				<xsl:element name="reference">
					<xsl:attribute name="idref">
						<xsl:value-of select="concat('uuid_',topic_characteristic_id)"/> <!-- Erzeugen des attribute_values -->
					</xsl:attribute>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>	
	
	<xsl:template match="multiplicity">
		<xsl:element name="multiplicity">
			<xsl:attribute name="id" select="concat('uuid_',id)"/>
			<xsl:element name="min_value">
				<xsl:value-of select="min_value"/>			
			</xsl:element>
			<xsl:if test="max_value">
				<xsl:element name="max_value">
					<xsl:value-of select="max_value"/>
				</xsl:element>
			</xsl:if>			
		</xsl:element>
	</xsl:template>
	
	<!-- Erzeugen der projects -->
	<xsl:template match="project">
		<xsl:element name="project">
			<xsl:attribute name="id">
				<xsl:value-of select="concat('uuid_',id)"/> <!-- Erzeugen des attribute_values -->
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
									<xsl:value-of select="concat('locale_',pt_locale_id,'.xml#','uuid_',pt_free_text_id)"/>
								</xsl:attribute>
							</xsl:element>
					</xsl:for-each>
				</xsl:element>
			</xsl:element>
			<xsl:if test="description">
				<xsl:element name="description">
					<xsl:element name="gmd:PT_FreeText" namespace="http://www.isotc211.org/2005/gmd">
						<xsl:variable name="descr_project" select="description"/>
						<xsl:for-each select="key('LCS_by_free_text_id',$descr_project)">
								<xsl:element name="gmd:textGroup" namespace="http://www.isotc211.org/2005/gmd">
									<xsl:attribute name="xlink:href" namespace="http://www.w3.org/1999/xlink">
										<xsl:value-of select="concat('locale_',pt_locale_id,'.xml#','uuid_',pt_free_text_id)"/>
									</xsl:attribute>
								</xsl:element>
						</xsl:for-each>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<xsl:if test="subproject_of">
				<xsl:element name="subproject_of">
					<xsl:element name="reference">
						<xsl:attribute name="idref">
							<xsl:value-of select="concat('uuid_',subproject_of)"/> <!-- Erzeugen des attribute_values -->
						</xsl:attribute>
					</xsl:element>
				</xsl:element>			
			</xsl:if>
		</xsl:element>
	</xsl:template>
	
	<!-- Erzeugen der Themen -->
	<xsl:template match="topic_characteristic/topic[not(.=following::topic_characteristic/topic)]">  <!-- Durchführung analog zu attribute_type_group -->
		<xsl:element name="topic">
			<xsl:variable name="id">
				<xsl:value-of select="."/>
			</xsl:variable>
			<xsl:attribute name="id">
				<xsl:value-of select="concat('uuid_',$id)"/>
			</xsl:attribute>	
			<xsl:element name="description">
				<xsl:attribute name="value_list_value">
					<xsl:value-of select="concat('value_lists.xml#uuid_',$id)"/> 
				</xsl:attribute>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<!-- Erzeugen der Themenausprägungen -->
	<xsl:template match="topic_characteristic">
		<xsl:element name="topic_characteristic">
			<xsl:attribute name="id">
				<xsl:value-of select="concat('uuid_',id)"/> <!-- Erzeugen des attribute_values -->
			</xsl:attribute>
			<xsl:element name="id">
				<xsl:value-of select="id"/>
			</xsl:element>
			<xsl:element name="description">
				<xsl:element name="gmd:PT_FreeText" namespace="http://www.isotc211.org/2005/gmd">
					<xsl:variable name="descr" select="description"/>
					<xsl:for-each select="key('LCS_by_free_text_id',$descr)"> 
							<xsl:element name="gmd:textGroup" namespace="http://www.isotc211.org/2005/gmd">
								<xsl:attribute name="xlink:href" namespace="http://www.w3.org/1999/xlink">
									<xsl:value-of select="concat('locale_',pt_locale_id,'.xml#','uuid_',pt_free_text_id)"/>
								</xsl:attribute>
							</xsl:element>
					</xsl:for-each>
				</xsl:element>
			</xsl:element>
			<xsl:element name="project">
				<xsl:element name="reference">
					<xsl:attribute name="idref">
						<xsl:value-of select="concat('uuid_',project_id)"/> <!-- Erzeugen des attribute_values -->
					</xsl:attribute>
				</xsl:element>
			</xsl:element>
			<xsl:element name="rel_topic">
				<xsl:element name="reference">
					<xsl:attribute name="idref">
						<xsl:value-of select="concat('uuid_',topic)"/> <!-- Erzeugen des attribute_values -->
					</xsl:attribute>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<!-- Erzeugen der topic_instanceen -->
	<xsl:template match="topic_instance">
		<xsl:element name="topic_instance">
			<xsl:variable name="id" select="id"/>
			<xsl:attribute name="id">
				<xsl:value-of select="concat('uuid_',id)"/> <!-- Erzeugen des attribute_values -->
			</xsl:attribute> 
			<xsl:element name="id">
				<xsl:value-of select="id"/>
			</xsl:element>
			<xsl:element name="rel_topic_characteristic">
				<xsl:element name="reference">
					<xsl:attribute name="idref">
						<xsl:value-of select="concat('uuid_',topic_characteristic_id)"/> <!-- Erzeugen des attribute_values -->
					</xsl:attribute>
				</xsl:element>
			</xsl:element>
			<xsl:for-each select="key('topic_instance_topic_instance_by_topic_instance_1',$id)">
					<xsl:element name="rel_topic_instance">
						<xsl:element name="reference">
							<xsl:attribute name="idref">
								<xsl:value-of select="concat('uuid_',topic_instance_2)"/> <!-- Erzeugen des attribute_values -->
							</xsl:attribute>
						</xsl:element>
						<xsl:element name="reference_relationship_type">
							<xsl:attribute name="idref">
								<xsl:value-of select="concat('uuid_',relationship_type_id)"/> <!-- Erzeugen des attribute_values -->
							</xsl:attribute>
						</xsl:element>
					</xsl:element>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>
	
</xsl:stylesheet>