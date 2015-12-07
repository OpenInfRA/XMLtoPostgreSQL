-- letzte Aktualisierung 2013-12-18


/*-----------------------------------------------------------------------------
## Nutzung von alphanumerischen Datentypen:
## - varchar -> Begrenzung auf max. 255 Zeichen, daher nur für Bezeichnungen
##   (Namen) von Objekten geeignet
## - text -> keine Zeichenbegrenzung, daher Nutzung für ausführliche
##   Beschreibungen zu einem Objekt
##
## Datentyp uuid
## - übernimmt die Speicherung von UUIDs
## - _x_ Relationen zeigen immer auf die uuid's der entsprechenden Objekte,
##   dadurch bleiben die Verbindungen datenbankübergreifend eindeutig
-----------------------------------------------------------------------------*/

-------------------
-- Erweiterungen --
-------------------
CREATE EXTENSION IF NOT EXISTS "plpgsql";
CREATE EXTENSION IF NOT EXISTS "postgis";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";


----------------------
-- Projektdatenbank --
----------------------

------------------------
-- Schemadefinitionen --
------------------------
-- Schema für die Projektdatenbank erstellen
CREATE SCHEMA projektdatenbank_v11;

-- Standard-Suchpfad auf neu erstelltes Schema ändern
SET search_path TO projektdatenbank_v11, public;


---------------------
-- Grundfunktionen --
---------------------
-- erzeugt eine UUID
CREATE OR REPLACE FUNCTION create_uuid()
  RETURNS uuid AS $$
    SELECT public.uuid_generate_v4();
  $$ LANGUAGE 'sql';

  
--------------------------
-- Tabellendefinitionen --
--------------------------
-- Mehrsprachigkeitstabelle - stellt die Verbindung zwischen der Übersetzungs-
-- tabelle und den Wertetabellen her.
CREATE TABLE "PT_FreeText"
(
  "Id" uuid NOT NULL PRIMARY KEY DEFAULT create_uuid()
);


-- Mehrsprachigkeitstabelle - beinhaltet genutzte Sprachkodierungen nach ISO
-- 639-2.
CREATE TABLE "Sprachkodierung"
(
  "Id" uuid NOT NULL PRIMARY KEY DEFAULT create_uuid(),
  "Sprachkodierung" varchar NOT NULL UNIQUE
);


-- Mehrsprachigkeitstabelle - beinhaltet genutzte Länderkodierungen nach ISO
-- 3166.
CREATE TABLE "Landkodierung"
(
  "Id" uuid NOT NULL PRIMARY KEY DEFAULT create_uuid(),
  "Landkodierung" varchar NOT NULL UNIQUE
);


-- Mehrsprachigkeitstabelle - beinhaltet genutzte Zeichenkodierungen nach ISO
-- 19115.
CREATE TABLE "Zeichenkodierung"
(
  "Id" uuid NOT NULL PRIMARY KEY DEFAULT create_uuid(),
  "Zeichenkodierung" varchar NOT NULL UNIQUE
);


-- Mehrsprachigkeitstabelle - beinhaltet die Lokalisierungseigenschaften
-- Sprache, Land und Zeichenkodierung. Trotz des möglichen NULL Wertes in
-- Landkodierung_Id, wird ein UNIQUE Constraint über Sprachkodierung_Id,
-- Landkodierung_Id und Zeichenkodierung_Id eingesetzt. Das gewährleistet
-- zumindest eine Einzigartigkeit, wenn Landkodierung_Id nicht NULL ist.
-- Zudem wird diese Tabelle eine überschaubare Anzahl an Datensätzen beinhalten
-- und ausschließlich über Administratoren gepflegt.
CREATE TABLE "PT_Locale"
(
  "Id" uuid NOT NULL PRIMARY KEY DEFAULT create_uuid(),
  "Sprachkodierung_Id" uuid NOT NULL REFERENCES "Sprachkodierung" ("Id"),
  "Landkodierung_Id" uuid REFERENCES "Landkodierung" ("Id"),
  "Zeichenkodierung_Id" uuid NOT NULL REFERENCES "Zeichenkodierung" ("Id"),
  CONSTRAINT pt_locale_unique_key UNIQUE ("Sprachkodierung_Id", "Landkodierung_Id", "Zeichenkodierung_Id")
);


-- Mehrsprachigkeitstabelle - beinhaltet alle Texte und die Verbindung zu den
-- Lokalisierungseigenschaften.
CREATE TABLE "LocalizedCharacterString"
(
  "PT_FreeText_Id" uuid NOT NULL REFERENCES "PT_FreeText" ("Id"),
  "PT_Locale_Id" uuid NOT NULL REFERENCES "PT_Locale" ("Id"),
  "Freitext" text NOT NULL,
  PRIMARY KEY ("PT_FreeText_Id", "PT_Locale_Id")
);


-- Beinhaltet den Namen und eine Beschreibung der zur Verfügung stehenden
-- Wertelisten
CREATE TABLE "WL_Werteliste"
(
  "Id" uuid NOT NULL PRIMARY KEY DEFAULT create_uuid(),
  "Name" uuid NOT NULL REFERENCES "PT_FreeText" ("Id"),
  "Beschreibung" uuid REFERENCES "PT_FreeText" ("Id")
);


-- Beinhaltet die einzelnen Werte der Wertelisten. Regelt zudem die
-- Sichtbarkeit der einzelnen Werte in den Wertelisten und deren
-- Zuordnung.
CREATE TABLE "WL_WertelistenWerte"
(
  "Id" uuid NOT NULL PRIMARY KEY DEFAULT create_uuid(),
  "Name" uuid NOT NULL REFERENCES "PT_FreeText" ("Id"),
  "Beschreibung" uuid REFERENCES "PT_FreeText" ("Id"),
  "Sichtbarkeit" boolean NOT NULL DEFAULT true,
  "gehoert_zu_Werteliste" uuid NOT NULL REFERENCES "WL_Werteliste" ("Id")
);


-- Beziehungstabelle für Wertelisten.
-- Die Richtung der Beziehung sollte in Leserichtung erfolgen: WL_Werteliste_1 Beziehung WL_Werteliste_2
CREATE TABLE "WL_Werteliste_x_WL_Werteliste"
(
  "WL_Werteliste_1" uuid NOT NULL REFERENCES "WL_Werteliste" ("Id"),
  "WL_Werteliste_2" uuid NOT NULL REFERENCES "WL_Werteliste" ("Id"),
  "Beziehungsart" uuid NOT NULL REFERENCES "WL_WertelistenWerte" ("Id"),
  PRIMARY KEY ("WL_Werteliste_1", "WL_Werteliste_2")
);


-- Beziehungstabelle für Wertelistenwerte.
-- Die Richtung der Beziehung sollte in Leserichtung erfolgen: WL_WertelistenWerte_1 Beziehung WL_WertelistenWerte_2
CREATE TABLE "WL_WertelistenWerte_x_WL_WertelistenWerte"
(
  "WL_WertelistenWerte_1" uuid NOT NULL REFERENCES "WL_WertelistenWerte" ("Id"),
  "WL_WertelistenWerte_2" uuid NOT NULL REFERENCES "WL_WertelistenWerte" ("Id"),
  "Beziehungsart" uuid NOT NULL REFERENCES "WL_WertelistenWerte" ("Id"),
  PRIMARY KEY ("WL_WertelistenWerte_1", "WL_WertelistenWerte_2")
);


-- Beschreibt die Multiplizität eines Attributtyps.
CREATE TABLE "Multiplizitaet"
(
  "Id" uuid NOT NULL PRIMARY KEY DEFAULT create_uuid(),
  "Min-Wert" integer NOT NULL,
  "Max-Wert" integer -- NULL Wert signalisiert eine ..* Multiplizität
);


-- Beinhaltet alle Eigenschaften eines Attributtyps.
CREATE TABLE "Attributtyp"
(
  "Id" uuid NOT NULL PRIMARY KEY DEFAULT create_uuid(),
  "Name" uuid NOT NULL REFERENCES "PT_FreeText" ("Id"),
  "Beschreibung" uuid REFERENCES "PT_FreeText" ("Id"),
  "Datentyp" uuid NOT NULL REFERENCES "WL_WertelistenWerte" ("Id"),
  "Einheit" uuid REFERENCES "WL_WertelistenWerte" ("Id"),
  "Wertebereich" uuid REFERENCES "WL_Werteliste" ("Id") -- Wertelistenwerte der zugeordneten Werteliste können in Attributwerte genutzt werden
);


-- Beinhaltet alle möglichen Beziehungstypen.
CREATE TABLE "Beziehungstyp"
(
  "Id" uuid NOT NULL PRIMARY KEY DEFAULT create_uuid(),
  "Referenz_auf" uuid NOT NULL REFERENCES "WL_WertelistenWerte"("Id"),
  "Beschreibung" uuid NOT NULL REFERENCES "WL_WertelistenWerte" ("Id")
);


-- Beziehungstabelle für Attributtypen.
-- Die Richtung der Beziehung sollte in Leserichtung erfolgen: Attributtyp_1 Beziehung Attributtyp_2
CREATE TABLE "Attributtyp_x_Attributtyp"
(
  "Attributtyp_1" uuid NOT NULL REFERENCES "Attributtyp" ("Id"),
  "Attributtyp_2" uuid NOT NULL REFERENCES "Attributtyp" ("Id"),
  "Beziehungsart" uuid NOT NULL REFERENCES "WL_WertelistenWerte" ("Id"),
  PRIMARY KEY ("Attributtyp_1", "Attributtyp_2")
);


-- Join Tabelle für Attributtypen und Attributtypgruppen.
CREATE TABLE "Attributtyp_x_Attributtyp_Gruppe"
(
  "Attributtyp_Id" uuid NOT NULL REFERENCES "Attributtyp" ("Id"),
  "Attributtyp_Gruppe" uuid NOT NULL REFERENCES "WL_WertelistenWerte" ("Id"),
  PRIMARY KEY ("Attributtyp_Id", "Attributtyp_Gruppe")
);


-- Beinhaltet das Hauptprojekt und alle Teilprojekte.
CREATE TABLE "Projekt"
(
  "Id" uuid NOT NULL PRIMARY KEY DEFAULT create_uuid(),
  "Name" uuid NOT NULL REFERENCES "PT_FreeText" ("Id"),
  "Beschreibung" uuid REFERENCES "PT_FreeText" ("Id"),
  "Teilprojekt_von" uuid REFERENCES "Projekt" ("Id")
);


-- Beinhaltet die Themenausprägungen für ein bestimmtes Thema zu einem
-- bestimmten Projekt.
CREATE TABLE "Themenauspraegung"
(
  "Id" uuid NOT NULL PRIMARY KEY DEFAULT create_uuid(),
  "Beschreibung" uuid NOT NULL REFERENCES "PT_FreeText" ("Id"),
  "Thema" uuid NOT NULL REFERENCES "WL_WertelistenWerte" ("Id"),
  "Projekt_Id" uuid NOT NULL REFERENCES "Projekt" ("Id")
);


-- Beinhaltet Themeninstanzen und deren Verbindung zu Themenausprägungen.
CREATE TABLE "Themeninstanz"
(
  "Id" uuid NOT NULL PRIMARY KEY DEFAULT create_uuid(),
  "Themenauspraegung_Id" uuid NOT NULL REFERENCES "Themenauspraegung" ("Id")
);


-- Regelt die Zuordnung von Attributtypen zu Themenausprägungen.
CREATE TABLE "Attributtypen_zur_Themenauspraegung"
(
  "Themenauspraegung_Id" uuid NOT NULL REFERENCES "Themenauspraegung" ("Id"),
  "Attributtyp_Id" uuid NOT NULL REFERENCES "Attributtyp" ("Id"),
  "Multiplizitaet" uuid NOT NULL REFERENCES "Multiplizitaet" ("Id"),
  "Standardwert" uuid REFERENCES "WL_WertelistenWerte" ("Id"),
  PRIMARY KEY ("Attributtyp_Id", "Themenauspraegung_Id")
);


-- Regelt die Zuordnung von Beziehungstypen zu Themenausprägungen.
CREATE TABLE "Beziehungstypen_zur_Themenauspraegung"
(
  "Themenauspraegung_Id" uuid NOT NULL REFERENCES "Themenauspraegung" ("Id"),
  "Beziehungstyp_Id" uuid REFERENCES "Beziehungstyp" ("Id"),
  "Multiplizitaet" uuid NOT NULL REFERENCES "Multiplizitaet" ("Id"),
  PRIMARY KEY ("Beziehungstyp_Id", "Themenauspraegung_Id")
);


-- Beziehungstabelle für Themeninstanzen.
-- Die Richtung der Beziehung sollte in Leserichtung erfolgen: Themeninstanz_1 Beziehung Themeninstanz_2
CREATE TABLE "Themeninstanz_x_Themeninstanz"
(
  "Id" uuid NOT NULL PRIMARY KEY DEFAULT create_uuid(),
  "Themeninstanz_1" uuid NOT NULL REFERENCES "Themeninstanz" ("Id"),
  "Themeninstanz_2" uuid NOT NULL REFERENCES "Themeninstanz" ("Id"),
  "Beziehungstyp_Id" uuid NOT NULL REFERENCES "Beziehungstyp" ("Id"),
  CONSTRAINT ti_x_ti_unique_key UNIQUE ("Themeninstanz_1", "Themeninstanz_2")
);


-- Beinhaltet alle Geometriedaten für Attributwerte.
CREATE TABLE "Geometrie_3d_SRID_0"
(
  "Id" uuid NOT NULL PRIMARY KEY DEFAULT create_uuid(),
  "Geometrie" geometry(geometryz) NOT NULL
);


-- Beinhaltet die Attributwerte zu den entsprechenden Themeninstanzen.
-- Die Attribute "Wertebereich_Id", "Geometrie_Id" und "Wert" sind exklusiv
-- oder.
-- Der Datentyp von "Attributwert" muss dem entsprechen, der im Attribut
-- "Datentyp" des zugehörigen Attributtyps spezifiziert ist.
CREATE TABLE "Attributwert"
(
  "Id" uuid NOT NULL PRIMARY KEY DEFAULT create_uuid(),
  "Attributtyp_Id" uuid NOT NULL REFERENCES "Attributtyp" ("Id"),
  "Themeninstanz_Id" uuid NOT NULL REFERENCES "Themeninstanz" ("Id"),
  "Wertebereich_Id" uuid REFERENCES "WL_WertelistenWerte" ("Id"), -- darf nur genutzt werden, wenn der zugehörige Attributtyp einen FK in Wertebereich auf denselben WL_Werteliste der WL_WertelistenWerte besitzt
  "Geometrie_Id" uuid REFERENCES "Geometrie_3d_SRID_0" ("Id"),
  "Wert" uuid REFERENCES "PT_FreeText" ("Id")
);