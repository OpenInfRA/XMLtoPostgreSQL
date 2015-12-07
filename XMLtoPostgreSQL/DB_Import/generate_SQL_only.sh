#!/bin/bash

echo "Import XML nach Postgresql"

schema_name=project_database_v12_imp

read -p "Name des Datenbankschemas eingeben, in das die Daten importiert werden sollen (Voreinstellung = $schema_name): " schema_name

if [ -z "$schema_name" ]; then
	schema_name=project_database_v12_imp
fi

for file in SQL_Script/*.sql ; do
	rm -f $file
done


if [ -f Import.sql ]
	then
		rm Import.sql
fi

# Validierung
javac ../Validierung/ValidateXML.java

exitcode=1

anzahl=0
for file in XML_Dokumente/locale_*.xml ; do 
    	if [ $exitcode -eq 1 ]
    		then
    			java -cp ../Validierung/ ValidateXML ../XSD/OpenInfRA_xsd_v12.xsd "$file"
    			(( exitcode = $? ))
    		fi
	(( anzahl++ ))
done

if [ $exitcode -eq 0 ]
	then
	echo "Aufgrund der Ungueltigkeit der Ausgangsdaten (Locale-Files) kann der Importprozess nicht fortgesetzt werden."
	exit
fi

if [ $anzahl -eq 0 ]
	then
		echo Uebersetzungscontainer sind nicht im Ordner XML_Dokumente enthalten.
fi

if [ -f XML_Dokumente/OpenInfRA_XML.xml ]
	then
		echo Start Validierung OpenInfRA_XML
		java -cp ../Validierung/ ValidateXML ../XSD/OpenInfRA_xsd_v12.xsd XML_Dokumente/OpenInfRA_XML.xml    	
    	(( exitcode = $? ))
    	echo End Validierung OpenInfRA_XML
    	if [ $exitcode -eq 0 ]
    		then
    			echo "Aufgrund der Ungueltigkeit der Ausgangsdaten (OpenInfRA_XML.xml) kann der Importprozess nicht fortgesetzt werden."
				exit
			fi
	else
		echo OpenInfRA_XML.xml ist nicht im Ordner XML_Dokumente enthalten.
fi

if [ -f XML_Dokumente/value_lists.xml ]
	then
		java -cp ../Validierung/ ValidateXML ../XSD/OpenInfRA_xsd_v12.xsd XML_Dokumente/value_lists.xml
    	(( exitcode = $? ))
    	if [ $exitcode -eq 0 ]
    		then
    			echo "Aufgrund der Ungueltigkeit der Ausgangsdaten (value_lists.xml) kann der Importprozess nicht fortgesetzt werden."
				exit
			fi
	else
		echo value_lists.xml ist nicht im Ordner XML_Dokumente enthalten.
fi

# Transformation
if [ -f XML_Dokumente/OpenInfRA_XML.xml ]
	then
		java -cp ../XML_Export_automatisiert/saxonb9/saxon9.jar net.sf.saxon.Transform -s:XML_Dokumente/OpenInfRA_XML.xml -xsl:XSLT/import_instanz.xslt spath="$schema_name"
fi

for file in XML_Dokumente/locale_*.xml ; do 
    	java -cp ../XML_Export_automatisiert/saxonb9/saxon9.jar net.sf.saxon.Transform -s:"$file" -xsl:XSLT/import_uebersetzungscontainer.xslt spath="$schema_name"
done

if [ -f XML_Dokumente/value_lists.xml ]
	then
		java -cp ../XML_Export_automatisiert/saxonb9/saxon9.jar net.sf.saxon.Transform -s:XML_Dokumente/value_lists.xml -xsl:XSLT/import_wertelisten.xslt spath="$schema_name"
fi


# Ueberpruefung
anzahl=0
for file in SQL_Script/locale_*.xml ; do 
        (( anzahl++ ))
done

if [ $anzahl -eq 0 ]
    then
        echo SQL Scripte für Übersetzungscontainer konnten nicht erzeugt werden.
	else
		echo SQL Scripte für Übersetzungscontainer wurden erzeugt.
fi


if [ -f SQL_Script/Import_wertelisten.sql ]
	then
		echo SQL Scripte für Wertelisten wurden erzeugt.
	else
		echo SQL Scripte für Wertelisten konnten nicht erzeugt werden.
fi

if [ -f SQL_Script/Import_instanz.sql ]
	then
		echo SQL Scripte für Instanzdokument wurden erzeugt.
	else
		echo SQL Scripte für Instanzdokument konnten nicht erzeugt werden.
fi