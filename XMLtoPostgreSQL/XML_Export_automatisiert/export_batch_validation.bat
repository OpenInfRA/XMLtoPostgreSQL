@echo off
echo Export Postgresql nach XML
echo.
set db_name=postgres
set user_name=postgres
set schema_name=project_database_v12
set path_name=C:\"Program Files (x86)"\PostgreSQL\9.3\bin\psql
set host=localhost
set port=5432
set destination_path=E:\OpenInfRA_XML-Schnittstelle\XML_Export_automatisiert\Datenbank_Exportdatei

set /p host=Host eingeben (Voreinstellung = %host%):
set /p port=Port eingeben (Voreinstellung = %port%):
set /p db_name=Datenbankname eingeben (Voreinstellung = %db_name%):
set /p user_name=Benutzername eingeben (Voreinstellung = %user_name%):
set /p schema_name=Name des Datenbankschemas eingeben (Voreinstellung = %schema_name%):
set /p path_name=Pfadangabe von psql eingeben (Voreinstellung = %path_name%):
set /p destination_path=Speicherort der Exportdatei eingeben (Voreinstellung = %destination_path%):

javac ../Validierung/ValidateXML.java

echo.
IF exist Ergebnis_XML\*.xml (
del Ergebnis_XML\*.xml
)
IF exist Datenbank_Exportdatei\*.xml (
del Datenbank_Exportdatei\*.xml
)
echo Datenbankexport:
echo.
%path_name% -h %host% -p %port% -U %user_name% -d %db_name% -a -c "COPY (select schema_to_xml('%schema_name%', false, true,'')) TO '%destination_path%\DB_Export.xml' WITH CSV QUOTE ' ' ENCODING 'UTF-8'; COPY (SELECT xmlelement(name attribute_value_geom, xmlattributes('http://www.opengis.net/gml'as """xmlns:gml"""), xmlagg(xmlelement(name geometry, xmlattributes("""id""" as id), XMLPARSE(CONTENT ST_AsGML("""geom"""))))) from """%schema_name%"""."""attribute_value_geom""") TO '%destination_path%\DB_Export_Geometry.xml' WITH CSV QUOTE ' ';COPY (SELECT xmlelement(name attribute_value_geomz, xmlattributes('http://www.opengis.net/gml'as """xmlns:gml"""), xmlagg(xmlelement(name geometryz, xmlattributes("""id""" as id), XMLPARSE(CONTENT ST_AsGML("""geom"""))))) from """%schema_name%"""."""attribute_value_geomz""") TO '%destination_path%\DB_Export_GeometryZ.xml' WITH CSV QUOTE ' '"
echo.

IF exist Datenbank_Exportdatei\DB_Export.xml (
	echo Daten wurden exportiert
	echo.
	java -cp Saxon\saxon9he.jar net.sf.saxon.Transform -s:Datenbank_Exportdatei\DB_Export.xml -xsl:XSLT\trafo_Instanzdokument.xslt
	IF exist Ergebnis_XML\OpenInfRA_XML.xml (
		echo OpenInfRA_XML.xml wurde generiert und wird validiert... 
		java  -cp ../Validierung/ ValidateXML ../XSD/OpenInfRA_xsd_v12.xsd Ergebnis_XML/OpenInfRA_XML.xml
	)ELSE (
		echo OpenInfRA_XML.xml wurde nicht generiert. 
	)
	echo.
	java -cp Saxon\saxon9he.jar net.sf.saxon.Transform -s:Datenbank_Exportdatei\DB_Export.xml -xsl:XSLT\trafo_Uebersetzungscontainer.xslt
	IF exist Ergebnis_XML\locale_*.xml (
		echo Uebersetzungscontainer wurden generiert und werden validiert...

		for %%f in (Ergebnis_XML\locale_*.xml) do java  -cp ../Validierung/ ValidateXML ../XSD/OpenInfRA_xsd_v12.xsd %%f
		
	)ELSE (
		echo Uebersetzungscontainer wurden nicht generiert. 
	)
	echo.
	java -cp Saxon\saxon9he.jar net.sf.saxon.Transform -s:Datenbank_Exportdatei\DB_Export.xml -xsl:XSLT\trafo_Wertelisten.xslt
	IF exist Ergebnis_XML\value_lists.xml (
		echo Wertelisten wurden generiert und werden validiert... 
		java  -cp ../Validierung/ ValidateXML ../XSD/OpenInfRA_xsd_v12.xsd Ergebnis_XML/value_lists.xml
	)ELSE (
		echo Wertelisten wurden nicht generiert. 
	)
)ELSE (
echo Daten wurden nicht aus der Datenbank exportiert. Eine Transformation kann nicht stattfinden. Bitte Ueberpruefen Sie Ihre Eingaben.
)
echo.
pause 
cls