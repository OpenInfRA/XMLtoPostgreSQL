@echo off
echo Import XML nach Postgresql 
echo.
set db_name=postgres
set user_name=postgres
set schema_name=project_database_v12_imp
set path_name=C:\"Program Files (x86)"\PostgreSQL\9.3\bin\psql
set host=localhost
set port=5432


set /p host=Host eingeben (Voreinstellung = %host%):
set /p port=Port eingeben (Voreinstellung = %port%):
set /p db_name=Datenbankname eingeben (Voreinstellung = %db_name%):
set /p user_name=Benutzername eingeben (Voreinstellung = %user_name%):
set /p schema_name=Name des Datenbankschemas eingeben, in das die Daten importiert werden sollen (Voreinstellung = %schema_name%):
set /p path_name=Pfadangabe von psql eingeben (Voreinstellung = %path_name%):


echo.
IF exist SQL_Script\*.sql (
del SQL_Script\*.sql
)
IF exist Import.sql (
del Import.sql
)

echo.
SETLOCAL ENABLEDELAYEDEXPANSION
javac ../Validierung/ValidateXML.java
set exitcode1=1

IF exist XML_Dokumente\locale_*.xml (
	for %%f in (XML_Dokumente\locale_*.xml) do (
		if !exitcode1!==1 (
			java  -cp ../Validierung/ ValidateXML ../XSD/OpenInfRA_xsd_v12.xsd %%f
			set exitcode1=!ERRORLEVEL!
		)
	)
)ELSE (
	echo Uebersetzungscontainer sind nicht im Ordner XML_Dokumente enthalten. 
)
echo.
IF exist XML_Dokumente\value_lists.xml (
	java  -cp ../Validierung/ ValidateXML ../XSD/OpenInfRA_xsd_v12.xsd XML_Dokumente\value_lists.xml 
	set exitcode2=!ERRORLEVEL!
)ELSE (
	echo Wertelisten sind nicht im Ordner XML_Dokumente enthalten. 
)
echo.
IF exist XML_Dokumente\OpenInfRA_XML.xml (
	java  -cp ../Validierung/ ValidateXML ../XSD/OpenInfRA_xsd_v12.xsd XML_Dokumente\OpenInfRA_XML.xml 
	set exitcode3=!ERRORLEVEL!
)ELSE (
	echo OpenInfRA_XML.xml ist nicht im Ordner XML_Dokumente enthalten. 
)
echo.

if !exitcode1!==1 (
	if !exitcode2!==1 (
		if !exitcode3!==1 (
			java -cp ..\XML_Export_automatisiert\saxonb9\saxon9.jar net.sf.saxon.Transform -s:XML_Dokumente\OpenInfRA_XML.xml -xsl:XSLT\import_instanz.xslt spath=%schema_name%

			for %%f in (XML_Dokumente\locale_*.xml) do java -cp ..\XML_Export_automatisiert\saxonb9\saxon9.jar net.sf.saxon.Transform -s:%%f -xsl:XSLT\import_uebersetzungscontainer.xslt spath=%schema_name%

			java -cp ..\XML_Export_automatisiert\saxonb9\saxon9.jar net.sf.saxon.Transform -s:XML_Dokumente\value_lists.xml -xsl:XSLT\import_wertelisten.xslt spath=%schema_name%
			
			echo.
			IF exist SQL_Script\Import_locale_*.sql (
				echo SQL Scripte fuer Uebersetzungscontainer wurden erzeugt.
				for %%f in (SQL_Script/Import_locale_*.sql) do >>"Import.sql" echo \i SQL_Script/%%f
			)ELSE (
				echo SQL Scripte fuer Uebersetzungscontainer konnten nicht erzeugt werden.
			)
				
			IF exist SQL_Script\Import_wertelisten.sql (
				echo SQL Scripte fuer Wertelisten wurden erzeugt.
				>>"Import.sql" echo \i SQL_Script/Import_wertelisten.sql 
			)ELSE (
				echo SQL Scripte fuer Wertelisten konnten nicht erzeugt werden.
			)
			IF exist SQL_Script\Import_instanz.sql (
				echo SQL Scripte fuer Instanzdokument wurden erzeugt.
				>>"Import.sql" echo \i SQL_Script/Import_instanz.sql
			)ELSE (
				echo SQL Scripte fuer Instanzdokument konnte nicht erzeugt werden.
			)
			pause 
			
			echo Datenbankimport:
			echo.
			%path_name% -h %host% -p %port% -U %user_name% -d %db_name% -f Import.sql	
		)else (
			echo Aufgrund der Ungueltigkeit der Ausgangsdaten kann der Importprozess nicht fortgesetzt werden.
		)
	)else (
		echo Aufgrund der Ungueltigkeit der Ausgangsdaten kann der Importprozess nicht fortgesetzt werden.
	)
)else (
	echo Aufgrund der Ungueltigkeit der Ausgangsdaten kann der Importprozess nicht fortgesetzt werden.
)
echo.
pause 
cls