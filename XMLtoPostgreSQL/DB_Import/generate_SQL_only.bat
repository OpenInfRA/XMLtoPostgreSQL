@echo off
echo Import XML nach Postgresql 

echo.
set schema_name=project_database_v12_imp
set /p schema_name=Name des Datenbankschemas eingeben, in das die Daten importiert werden sollen (Voreinstellung = %schema_name%):

echo.
IF exist SQL_Script\*.sql (
del SQL_Script\*.sql
)
IF exist Import.sql (
del Import.sql
)

echo.
IF exist XML_Dokumente\OpenInfRA_XML.xml (
		java -cp ..\XML_Export_automatisiert\saxonb9\saxon9.jar net.sf.saxon.Transform -s:XML_Dokumente\OpenInfRA_XML.xml -xsl:XSLT\import_instanz.xslt spath=%schema_name%
	)ELSE (
		echo OpenInfRA_XML.xml ist nicht im Ordner XML_Dokumente enthalten. 
	)
	echo.
	
	IF exist XML_Dokumente\locale_*.xml (
		for %%f in (XML_Dokumente\locale_*.xml) do java -cp ..\XML_Export_automatisiert\saxonb9\saxon9.jar net.sf.saxon.Transform -s:%%f -xsl:XSLT\import_uebersetzungscontainer.xslt spath=%schema_name%
	)ELSE (
		echo Uebersetzungscontainer sind nicht im Ordner XML_Dokumente enthalten. 
	)
	echo.
	
	IF exist XML_Dokumente\value_lists.xml (
		java -cp ..\XML_Export_automatisiert\saxonb9\saxon9.jar net.sf.saxon.Transform -s:XML_Dokumente\value_lists.xml -xsl:XSLT\import_wertelisten.xslt spath=%schema_name%
	)ELSE (
		echo Wertelisten sind nicht im Ordner XML_Dokumente enthalten. 
	)

echo.

IF exist SQL_Script\Import_locale_*.sql (
	echo SQL Scripte für Übersetzungscontainer wurden erzeugt.
)ELSE (
	echo SQL Scripte für Übersetzungscontainer konnten nicht erzeugt werden.
)
	
IF exist SQL_Script\Import_wertelisten.sql (
	echo SQL Scripte für Wertelisten wurden erzeugt.
)ELSE (
	echo SQL Scripte für Wertelisten konnten nicht erzeugt werden.
)
IF exist SQL_Script\Import_instanz.sql (
	echo SQL Scripte für Instanzdokument wurden erzeugt.
)ELSE (
	echo SQL Scripte für Instanzdokument konnte nicht erzeugt werden.
)

echo.
pause 
cls