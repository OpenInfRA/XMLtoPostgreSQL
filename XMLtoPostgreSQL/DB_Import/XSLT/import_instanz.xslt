<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:math="/java.lang.Math" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:fn="http://www.w3.org/2004/10/xpath-functions" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:OpenInfRA="OpenInfRA" xmlns:uuid="java:java.util.UUID">
	<xsl:output method="text" indent="yes"/>
	<xsl:variable name="apos" select='"&apos;"'/>
	<xsl:param name="spath" select="spath"/>
	<xsl:key name="attribute_type_group_by_Id" match="OpenInfRA:attribute_type_group" use="@id" />
	<xsl:key name="topic_by_Id" match="OpenInfRA:topic" use="@id" />

	<xsl:template match="/*">
		<xsl:result-document method="text" href="SQL_Script/Import_instanz.sql">
			<xsl:value-of select="concat('SET search_path TO ',$spath,', public;')"/>
			<xsl:text>&#10;</xsl:text>
			<xsl:apply-templates select="//OpenInfRA:attribute_type"/>
			<xsl:apply-templates select="//OpenInfRA:attribute_type/OpenInfRA:rel_attribute_type"/>
			<xsl:apply-templates select="//OpenInfRA:relationship_type"/>
			<xsl:apply-templates select="//OpenInfRA:project"/>
			<xsl:apply-templates select="//OpenInfRA:project/OpenInfRA:subproject_of"/>
			<xsl:apply-templates select="//OpenInfRA:topic_characteristic"/>
			<xsl:apply-templates select="//OpenInfRA:multiplicity"/>
			<xsl:apply-templates select="//OpenInfRA:attribute_type_to_topic_characteristic"/>
			<xsl:apply-templates select="//OpenInfRA:relationship_type_to_topic_characteristic"/>
			<xsl:apply-templates select="//OpenInfRA:topic_instance"/>
			<xsl:apply-templates select="//OpenInfRA:topic_instance/OpenInfRA:rel_topic_instance"/>
			<xsl:apply-templates select="//OpenInfRA:attribute_value"/>
		</xsl:result-document>
	</xsl:template>

	<xsl:template match="//OpenInfRA:attribute_type">
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
		<xsl:variable name="data_type">
			<xsl:variable name="sub" select="substring-after(OpenInfRA:data_type/@value_list_value,'uuid_')"/>
			<xsl:value-of select="concat($apos,$sub,$apos)"/>
		</xsl:variable>
		<xsl:variable name="unit">
			<xsl:choose>
				<xsl:when test="OpenInfRA:unit">
					<xsl:variable name="sub" select="substring-after(OpenInfRA:unit/@value_list_value,'uuid_')"/> 
					<xsl:value-of select="concat($apos,$sub,$apos)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="'NULL'"/>	
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="domain">
			<xsl:choose>
				<xsl:when test="OpenInfRA:domain">
					<xsl:variable name="sub" select="substring-after(OpenInfRA:domain/@value_list,'uuid_')"/> 
					<xsl:value-of select="concat($apos,$sub,$apos)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="'NULL'"/>	
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="concat('INSERT INTO &quot;attribute_type&quot; VALUES (' ,$Id, ', ' ,$name, ', ' , $description, ', ' ,$data_type,', ',$unit,', ',$domain,');')"/>
		<xsl:text>&#10;</xsl:text>
		<xsl:for-each select="OpenInfRA:rel_attribute_type_group">
			<xsl:variable name="group_VL">
				<xsl:choose>
					<xsl:when test="OpenInfRA:reference">
						<xsl:value-of select="key('attribute_type_group_by_Id',OpenInfRA:reference/@idref)/OpenInfRA:description/@value_list_value"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="OpenInfRA:attribute_type_group/OpenInfRA:description/@value_list_value"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="sub" select="substring-after($group_VL,'uuid_')"/>
			<xsl:variable name="group" select="concat($apos,$sub,$apos)"/>
			<xsl:value-of select="concat('INSERT INTO &quot;attribute_type_group&quot; VALUES (' ,$Id, ', ' ,$group, ');')"/>
			<xsl:text>&#10;</xsl:text>
		</xsl:for-each>
	</xsl:template>	
	
	<xsl:template match="//OpenInfRA:attribute_type/OpenInfRA:rel_attribute_type">
		<xsl:variable name="Id" select="concat($apos,parent::*/OpenInfRA:id,$apos)"/>
		<xsl:variable name="sub">
			<xsl:choose>
				<xsl:when test="OpenInfRA:reference">
					<xsl:value-of select="substring-after(OpenInfRA:reference/@idref,'uuid_')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring-after(OpenInfRA:attribute_type/@id,'uuid_')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="at2" select="concat($apos,$sub,$apos)"/>
		<xsl:variable name="sub2" select="substring-after(OpenInfRA:SKOS_relationship/@value_list_value,'uuid_')"/>
		<xsl:variable name="SKOS" select="concat($apos,$sub2,$apos)"/>
		<xsl:value-of select="concat('INSERT INTO &quot;attribute_type_x_attribute_type&quot; VALUES (' ,$Id, ', ' ,$at2, ', ' , $SKOS, ');')"/>
		<xsl:text>&#10;</xsl:text>
	</xsl:template>
	
	<xsl:template match="//OpenInfRA:relationship_type">
		<xsl:variable name="Id" select="concat($apos,OpenInfRA:id,$apos)"/>
		<xsl:variable name="sub1" select="substring-after(OpenInfRA:reference_to/@value_list_value,'uuid_')"/>
		<xsl:variable name="reference" select="concat($apos,$sub1,$apos)"/>
		<xsl:variable name="sub2" select="substring-after(OpenInfRA:description/@value_list_value,'uuid_')"/>
		<xsl:variable name="description" select="concat($apos,$sub2,$apos)"/>
		<xsl:value-of select="concat('INSERT INTO &quot;relationship_type&quot; VALUES (' ,$Id, ', ' ,$reference, ', ' , $description, ');')"/>
		<xsl:text>&#10;</xsl:text>
	</xsl:template>
	
	<xsl:template match="//OpenInfRA:project">
		<xsl:if test="@id">
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
			<xsl:variable name="null" select="'NULL'"/>
			<xsl:value-of select="concat('INSERT INTO &quot;project&quot; VALUES (' ,$Id, ', ' ,$name, ', ' , $description, ', ' ,$null,');')"/>
			<xsl:text>&#10;</xsl:text>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="//OpenInfRA:project/OpenInfRA:subproject_of">
		<xsl:variable name="id" select="concat($apos,parent::*/OpenInfRA:id,$apos)"/>
		<xsl:variable name="sub">
			<xsl:choose>
				<xsl:when test="OpenInfRA:reference">
					<xsl:value-of select="substring-after(OpenInfRA:reference/@idref,'uuid_')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring-after(OpenInfRA:project/@id,'uuid_')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="subproject" select="concat($apos,$sub,$apos)"/>
		<xsl:value-of select="concat('UPDATE &quot;project&quot; SET &quot;subproject_of&quot; = ' ,$subproject, ' WHERE  &quot;id&quot; =' ,$id,';')"/>
		<xsl:text>&#10;</xsl:text>
	</xsl:template>
	
	<xsl:template match="//OpenInfRA:topic_characteristic">
		<xsl:variable name="Id" select="concat($apos,OpenInfRA:id,$apos)"/>
		<xsl:variable name="description">
			<xsl:for-each select="OpenInfRA:description/gmd:PT_FreeText/gmd:textGroup/@xlink:href">
				<xsl:if test="position() = 1">
					<xsl:variable name="sub" select="substring-after(.,'uuid_')"/>
					<xsl:value-of select="concat($apos,$sub,$apos)"/>  
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="topic">
			<xsl:for-each select="OpenInfRA:rel_topic">
				<xsl:variable name="vl">
					<xsl:choose>
						<xsl:when test="OpenInfRA:reference">
							<xsl:value-of select="key('topic_by_Id',OpenInfRA:reference/@idref)/OpenInfRA:description/@value_list_value"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="OpenInfRA:topic/OpenInfRA:description/@value_list_value"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="sub" select="substring-after($vl,'uuid_')"/>
				<xsl:value-of select="concat($apos,$sub,$apos)"/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="sub">
			<xsl:choose>
				<xsl:when test="OpenInfRA:project/OpenInfRA:reference">
					<xsl:value-of select="substring-after(OpenInfRA:project/OpenInfRA:reference/@idref,'uuid_')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring-after(OpenInfRA:project/OpenInfRA:project/@id,'uuid_')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="project" select="concat($apos,$sub,$apos)"/>
		<xsl:value-of select="concat('INSERT INTO &quot;topic_characteristic&quot; VALUES (' ,$Id, ', ' ,$description, ', ' , $topic, ', ' ,$project,');')"/>
		<xsl:text>&#10;</xsl:text>
	</xsl:template>
	
	<xsl:template match="//OpenInfRA:multiplicity">
		<xsl:if test="@id">
			<xsl:variable name="sub" select="substring-after(@id,'uuid_')"/>
			<xsl:variable name="Id" select="concat($apos,$sub,$apos)"/>
			<xsl:variable name="min" select="concat($apos,OpenInfRA:min_value,$apos)"/>
			<xsl:variable name="max">
				<xsl:choose>
					<xsl:when test="OpenInfRA:max_value">
						<xsl:value-of select="concat($apos,OpenInfRA:max_value,$apos)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="'NULL'"/>	
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:value-of select="concat('INSERT INTO &quot;multiplicity&quot; VALUES (' ,$Id, ', ' ,$min, ', ' , $max, ');')"/>
			<xsl:text>&#10;</xsl:text>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="//OpenInfRA:attribute_type_to_topic_characteristic">
		<xsl:variable name="sub">
			<xsl:choose>
				<xsl:when test="OpenInfRA:rel_topic_characteristic/OpenInfRA:reference">
					<xsl:value-of select="substring-after(OpenInfRA:rel_topic_characteristic/OpenInfRA:reference/@idref,'uuid_')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring-after(OpenInfRA:rel_topic_characteristic/OpenInfRA:topic_characteristic/@id,'uuid_')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="topic_characteristic" select="concat($apos,$sub,$apos)"/>
		<xsl:variable name="sub2">
			<xsl:choose>
				<xsl:when test="OpenInfRA:rel_attribute_type/OpenInfRA:reference">
					<xsl:value-of select="substring-after(OpenInfRA:rel_attribute_type/OpenInfRA:reference/@idref,'uuid_')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring-after(OpenInfRA:rel_attribute_type/OpenInfRA:attribute_type/@id,'uuid_')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="attribute_type" select="concat($apos,$sub2,$apos)"/>
		<xsl:variable name="sub3">
			<xsl:choose>
				<xsl:when test="OpenInfRA:multiplicity/OpenInfRA:reference">
					<xsl:value-of select="substring-after(OpenInfRA:multiplicity/OpenInfRA:reference/@idref,'uuid_')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring-after(OpenInfRA:multiplicity/OpenInfRA:multiplicity/@id,'uuid_')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="multi" select="concat($apos,$sub3,$apos)"/>
		<xsl:variable name="default">
			<xsl:choose>
				<xsl:when test="OpenInfRA:default_value">
					<xsl:variable name="sub4" select="substring-after(OpenInfRA:default_value/@value_list_value,'uuid_')"/>
					<xsl:value-of select="concat($apos,$sub4,$apos)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="'NULL'"/>	
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="concat('INSERT INTO &quot;attribute_type_to_topic_characteristic&quot; VALUES (' ,$topic_characteristic, ', ' ,$attribute_type, ', ' , $multi, ', ' ,$default,');')"/>
		<xsl:text>&#10;</xsl:text>
	</xsl:template>
	
	<xsl:template match="//OpenInfRA:relationship_type_to_topic_characteristic">
		<xsl:variable name="sub">
			<xsl:choose>
				<xsl:when test="OpenInfRA:rel_topic_characteristic/OpenInfRA:reference">
					<xsl:value-of select="substring-after(OpenInfRA:rel_topic_characteristic/OpenInfRA:reference/@idref,'uuid_')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring-after(OpenInfRA:rel_topic_characteristic/OpenInfRA:topic_characteristic/@id,'uuid_')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="topic_characteristic" select="concat($apos,$sub,$apos)"/>
		<xsl:variable name="sub2">
			<xsl:choose>
				<xsl:when test="OpenInfRA:rel_relationship_type/OpenInfRA:reference">
					<xsl:value-of select="substring-after(OpenInfRA:rel_relationship_type/OpenInfRA:reference/@idref,'uuid_')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring-after(OpenInfRA:rel_relationship_type/OpenInfRA:relationship_type/@id,'uuid_')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="relationship_type" select="concat($apos,$sub2,$apos)"/>
		<xsl:variable name="sub3">
			<xsl:choose>
				<xsl:when test="OpenInfRA:multiplicity/OpenInfRA:reference">
					<xsl:value-of select="substring-after(OpenInfRA:multiplicity/OpenInfRA:reference/@idref,'uuid_')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring-after(OpenInfRA:multiplicity/OpenInfRA:multiplicity/@id,'uuid_')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="multi" select="concat($apos,$sub3,$apos)"/>
		<xsl:value-of select="concat('INSERT INTO &quot;relationship_type_to_topic_characteristic&quot; VALUES (' ,$topic_characteristic, ', ' ,$relationship_type, ', ' , $multi, ');')"/>
		<xsl:text>&#10;</xsl:text>
	</xsl:template>
	
	<xsl:template match="//OpenInfRA:topic_instance">
		<xsl:variable name="Id" select="concat($apos,OpenInfRA:id,$apos)"/>
		<xsl:variable name="sub">
			<xsl:choose>
				<xsl:when test="OpenInfRA:rel_topic_characteristic/OpenInfRA:reference">
					<xsl:value-of select="substring-after(OpenInfRA:rel_topic_characteristic/OpenInfRA:reference/@idref,'uuid_')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring-after(OpenInfRA:rel_topic_characteristic/OpenInfRA:topic_characteristic/@id,'uuid_')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="topic_characteristic" select="concat($apos,$sub,$apos)"/>
		<xsl:value-of select="concat('INSERT INTO &quot;topic_instance&quot; VALUES (' ,$Id, ', ' ,$topic_characteristic,');')"/>
		<xsl:text>&#10;</xsl:text>
	</xsl:template>
	
	<xsl:template match="//OpenInfRA:topic_instance/OpenInfRA:rel_topic_instance">
		<xsl:variable name="Id" select="concat($apos,parent::*/OpenInfRA:id,$apos)"/>
		<xsl:variable name="sub">
			<xsl:choose>
				<xsl:when test="OpenInfRA:reference">
					<xsl:value-of select="substring-after(OpenInfRA:reference/@idref,'uuid_')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring-after(OpenInfRA:topic_instance/@id,'uuid_')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="topic_instance2" select="concat($apos,$sub,$apos)"/>
		<xsl:variable name="sub2">
			<xsl:choose>
				<xsl:when test="OpenInfRA:reference_relationship_type">
					<xsl:value-of select="substring-after(OpenInfRA:reference_relationship_type/@idref,'uuid_')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring-after(OpenInfRA:reference_relationship_type/OpenInfRA:relationship_type/@id,'uuid_')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="relationship_type" select="concat($apos,$sub2,$apos)"/>
		<xsl:value-of select="concat('INSERT INTO &quot;topic_instance_x_topic_instance&quot; VALUES (',$apos,uuid:randomUUID(),$apos, ',' ,$Id, ', ' ,$topic_instance2, ', ' , $relationship_type, ');')"/>
		<xsl:text>&#10;</xsl:text>
	</xsl:template>
	
	<xsl:template match="//OpenInfRA:attribute_value">
		<xsl:variable name="sub" select="substring-after(@id,'uuid_')"/>
		<xsl:variable name="Id" select="concat($apos,$sub,$apos)"/>
		<xsl:variable name="sub2">
			<xsl:choose>
				<xsl:when test="OpenInfRA:rel_attribute_type/OpenInfRA:reference">
					<xsl:value-of select="substring-after(OpenInfRA:rel_attribute_type/OpenInfRA:reference/@idref,'uuid_')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring-after(OpenInfRA:rel_attribute_type/OpenInfRA:attribute_type/@id,'uuid_')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="attribute_type" select="concat($apos,$sub2,$apos)"/>
		<xsl:variable name="sub3">
			<xsl:choose>
				<xsl:when test="OpenInfRA:rel_topic_instance/OpenInfRA:reference">
					<xsl:value-of select="substring-after(OpenInfRA:rel_topic_instance/OpenInfRA:reference/@idref,'uuid_')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring-after(OpenInfRA:rel_topic_instance/OpenInfRA:topic_instance/@id,'uuid_')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="topic_instance" select="concat($apos,$sub3,$apos)"/>
		<xsl:if test="OpenInfRA:domain">
			<xsl:variable name="sub4" select="substring-after(OpenInfRA:domain/@value_list_value,'uuid_')"/>
			<xsl:variable name="domain" select="concat($apos,$sub4,$apos)"/>
			<xsl:value-of select="concat('INSERT INTO &quot;attribute_value_domain&quot; VALUES (' ,$Id, ', ' ,$attribute_type, ', ' , $topic_instance,  ', ' ,$domain, ');')"/>
			<xsl:text>&#10;</xsl:text>
		</xsl:if>
		<xsl:if test="OpenInfRA:value">
			<xsl:variable name="value">
				<xsl:for-each select="OpenInfRA:value/gmd:PT_FreeText/gmd:textGroup/@xlink:href">
					<xsl:if test="position() = 1">
						<xsl:variable name="sub" select="substring-after(.,'uuid_')"/>
						<xsl:value-of select="concat($apos,$sub,$apos)"/>  
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="concat('INSERT INTO &quot;attribute_value_value&quot; VALUES (' ,$Id, ', ' ,$attribute_type, ', ' , $topic_instance,  ', ' ,$value, ');')"/>
			<xsl:text>&#10;</xsl:text>
		</xsl:if>
		<xsl:if test="OpenInfRA:geometry">
			<xsl:variable name="geom">
				<xsl:apply-templates select="OpenInfRA:geometry/*" mode="serialize"/>
			</xsl:variable>
			<xsl:value-of select="concat('INSERT INTO &quot;attribute_value_geom&quot; VALUES (' ,$Id, ', ' ,$attribute_type, ', ' , $topic_instance,  ', ' ,'ST_GeomFromGML(',$apos,normalize-space($geom),$apos, '));')"/>
			<xsl:text>&#10;</xsl:text>
		</xsl:if>
		<xsl:if test="OpenInfRA:geometryZ">
			<xsl:variable name="geomZ">
				<xsl:apply-templates select="OpenInfRA:geometryZ/*" mode="serialize"/>
			</xsl:variable>
			<xsl:value-of select="concat('INSERT INTO &quot;attribute_value_geomz&quot; VALUES (' ,$Id, ', ' ,$attribute_type, ', ' , $topic_instance,  ', ' ,'ST_GeomFromGML(',$apos,normalize-space($geomZ),$apos, '));')"/>
			<xsl:text>&#10;</xsl:text>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*" mode="serialize">
		<xsl:text>&lt;</xsl:text>
		<xsl:value-of select="name()"/>
		<xsl:apply-templates select="@*" mode="serialize" />
		<xsl:choose>
			<xsl:when test="node()">
				<xsl:text>&gt;</xsl:text>
				<xsl:apply-templates mode="serialize" />
				<xsl:text>&lt;/</xsl:text>
				<xsl:value-of select="name()"/>
				<xsl:text>&gt;</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text> /&gt;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="@*" mode="serialize">
		<xsl:text> </xsl:text>
		<xsl:value-of select="name()"/>
		<xsl:text>="</xsl:text>
		<xsl:value-of select="."/>
		<xsl:text>"</xsl:text>
	</xsl:template>

	<xsl:template match="text()" mode="serialize">
		<xsl:value-of select="."/>
	</xsl:template>
	
</xsl:stylesheet>