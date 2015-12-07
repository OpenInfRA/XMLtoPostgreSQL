-- letzte Aktualisierung 2014-04-24


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
CREATE SCHEMA project_database_v12;

-- Standard-Suchpfad auf neu erstelltes Schema ändern
SET search_path TO project_database_v12, public;


---------------------
-- Grundfunktionen --
---------------------
-- erzeugt eine UUID
CREATE OR REPLACE FUNCTION public.create_uuid()
  RETURNS uuid AS $$
    SELECT public.uuid_generate_v4();
  $$ LANGUAGE 'sql';

  
--------------------------
-- Tabellendefinitionen --
--------------------------
-- Mehrsprachigkeitstabelle - stellt die Verbindung zwischen der Übersetzungs-
-- tabelle und den Wertetabellen her.
CREATE TABLE "pt_free_text"
(
  "id" uuid NOT NULL PRIMARY KEY DEFAULT create_uuid()
);


-- Mehrsprachigkeitstabelle - beinhaltet genutzte Sprachkodierungen nach ISO
-- 639-2.
CREATE TABLE "language_code"
(
  "id" uuid NOT NULL PRIMARY KEY DEFAULT create_uuid(),
  "language_code" varchar NOT NULL UNIQUE
);


-- Mehrsprachigkeitstabelle - beinhaltet genutzte Länderkodierungen nach ISO
-- 3166.
CREATE TABLE "country_code"
(
  "id" uuid NOT NULL PRIMARY KEY DEFAULT create_uuid(),
  "country_code" varchar NOT NULL UNIQUE
);


-- Mehrsprachigkeitstabelle - beinhaltet genutzte Zeichenkodierungen nach ISO
-- 19115.
CREATE TABLE "character_code"
(
  "id" uuid NOT NULL PRIMARY KEY DEFAULT create_uuid(),
  "character_code" varchar NOT NULL UNIQUE
);


-- Mehrsprachigkeitstabelle - beinhaltet die Lokalisierungseigenschaften
-- Sprache, Land und Zeichenkodierung. Trotz des möglichen NULL Wertes in
-- country_code_id, wird ein UNIQUE Constraint über language_code_id,
-- country_code_id und character_code_id eingesetzt. Das gewährleistet
-- zumindest eine Einzigartigkeit, wenn country_code_id nicht NULL ist.
-- Zudem wird diese Tabelle eine überschaubare Anzahl an Datensätzen beinhalten
-- und ausschließlich über Administratoren gepflegt.
CREATE TABLE "pt_locale"
(
  "id" uuid NOT NULL PRIMARY KEY DEFAULT create_uuid(),
  "language_code_id" uuid NOT NULL REFERENCES "language_code" ("id"),
  "country_code_id" uuid REFERENCES "country_code" ("id"),
  "character_code_id" uuid NOT NULL REFERENCES "character_code" ("id"),
  CONSTRAINT pt_locale_unique_key UNIQUE ("language_code_id", "country_code_id", "character_code_id")
);


-- Mehrsprachigkeitstabelle - beinhaltet alle Texte und die Verbindung zu den
-- Lokalisierungseigenschaften.
CREATE TABLE "localized_character_string"
(
  "pt_free_text_id" uuid NOT NULL REFERENCES "pt_free_text" ("id"),
  "pt_locale_id" uuid NOT NULL REFERENCES "pt_locale" ("id"),
  "free_text" text NOT NULL,
  PRIMARY KEY ("pt_free_text_id", "pt_locale_id")
);


-- Beinhaltet den Namen und eine Beschreibung der zur Verfügung stehenden
-- Wertelisten
CREATE TABLE "value_list"
(
  "id" uuid NOT NULL PRIMARY KEY DEFAULT create_uuid(),
  "name" uuid NOT NULL REFERENCES "pt_free_text" ("id"),
  "description" uuid REFERENCES "pt_free_text" ("id")
);


-- Beinhaltet die einzelnen Werte der Wertelisten. Regelt zudem die
-- Sichtbarkeit der einzelnen Werte in den Wertelisten und deren
-- Zuordnung.
CREATE TABLE "value_list_values"
(
  "id" uuid NOT NULL PRIMARY KEY DEFAULT create_uuid(),
  "name" uuid NOT NULL REFERENCES "pt_free_text" ("id"),
  "description" uuid REFERENCES "pt_free_text" ("id"),
  "visibility" boolean NOT NULL DEFAULT true,
  "belongs_to_value_list" uuid NOT NULL REFERENCES "value_list" ("id")
);


-- Beziehungstabelle für Wertelisten.
-- Die Richtung der Beziehung sollte in Leserichtung erfolgen: value_list_1 Beziehung value_list_2
CREATE TABLE "value_list_x_value_list"
(
  "value_list_1" uuid NOT NULL REFERENCES "value_list" ("id"),
  "value_list_2" uuid NOT NULL REFERENCES "value_list" ("id"),
  "relationship" uuid NOT NULL REFERENCES "value_list_values" ("id"),
  PRIMARY KEY ("value_list_1", "value_list_2")
);


-- Beziehungstabelle für Wertelistenwerte.
-- Die Richtung der Beziehung sollte in Leserichtung erfolgen: value_list_values_1 Beziehung value_list_values_2
CREATE TABLE "value_list_values_x_value_list_values"
(
  "value_list_values_1" uuid NOT NULL REFERENCES "value_list_values" ("id"),
  "value_list_values_2" uuid NOT NULL REFERENCES "value_list_values" ("id"),
  "relationship" uuid NOT NULL REFERENCES "value_list_values" ("id"),
  PRIMARY KEY ("value_list_values_1", "value_list_values_2")
);


-- Beschreibt die Multiplizität eines Attributtyps.
CREATE TABLE "multiplicity"
(
  "id" uuid NOT NULL PRIMARY KEY DEFAULT create_uuid(),
  "min_value" integer NOT NULL,
  "max_value" integer -- NULL Wert signalisiert eine ..* Multiplizität
);


-- Beinhaltet alle Eigenschaften eines Attributtyps.
CREATE TABLE "attribute_type"
(
  "id" uuid NOT NULL PRIMARY KEY DEFAULT create_uuid(),
  "name" uuid NOT NULL REFERENCES "pt_free_text" ("id"),
  "description" uuid REFERENCES "pt_free_text" ("id"),
  "data_type" uuid NOT NULL REFERENCES "value_list_values" ("id"),
  "unit" uuid REFERENCES "value_list_values" ("id"),
  "domain" uuid REFERENCES "value_list" ("id") -- Wertelistenwerte der zugeordneten Werteliste können in Attributwerte genutzt werden
);


-- Beinhaltet alle möglichen Beziehungstypen.
CREATE TABLE "relationship_type"
(
  "id" uuid NOT NULL PRIMARY KEY DEFAULT create_uuid(),
  "reference_to" uuid NOT NULL REFERENCES "value_list_values"("id"),
  "description" uuid NOT NULL REFERENCES "value_list_values" ("id")
);


-- Beziehungstabelle für Attributtypen.
-- Die Richtung der Beziehung sollte in Leserichtung erfolgen: attribute_type_1 Beziehung attribute_type_2
CREATE TABLE "attribute_type_x_attribute_type"
(
  "attribute_type_1" uuid NOT NULL REFERENCES "attribute_type" ("id"),
  "attribute_type_2" uuid NOT NULL REFERENCES "attribute_type" ("id"),
  "relationship" uuid NOT NULL REFERENCES "value_list_values" ("id"),
  PRIMARY KEY ("attribute_type_1", "attribute_type_2")
);


-- Join Tabelle für Attributtypen und Attributtypgruppen.
CREATE TABLE "attribute_type_group"
(
  "attribute_type_id" uuid NOT NULL REFERENCES "attribute_type" ("id"),
  "attribute_type_group" uuid NOT NULL REFERENCES "value_list_values" ("id"),
  PRIMARY KEY ("attribute_type_id", "attribute_type_group")
);


-- Beinhaltet das Hauptprojekt und alle Teilprojekte.
CREATE TABLE "project"
(
  "id" uuid NOT NULL PRIMARY KEY DEFAULT create_uuid(),
  "name" uuid NOT NULL REFERENCES "pt_free_text" ("id"),
  "description" uuid REFERENCES "pt_free_text" ("id"),
  "subproject_of" uuid REFERENCES "project" ("id")
);


-- Beinhaltet die Themenausprägungen für ein bestimmtes Thema zu einem
-- bestimmten Projekt.
CREATE TABLE "topic_characteristic"
(
  "id" uuid NOT NULL PRIMARY KEY DEFAULT create_uuid(),
  "description" uuid NOT NULL REFERENCES "pt_free_text" ("id"),
  "topic" uuid NOT NULL REFERENCES "value_list_values" ("id"),
  "project_id" uuid NOT NULL REFERENCES "project" ("id")
);


-- Beinhaltet Themeninstanzen und deren Verbindung zu Themenausprägungen.
CREATE TABLE "topic_instance"
(
  "id" uuid NOT NULL PRIMARY KEY DEFAULT create_uuid(),
  "topic_characteristic_id" uuid NOT NULL REFERENCES "topic_characteristic" ("id")
);


-- Regelt die Zuordnung von Attributtypen zu Themenausprägungen.
CREATE TABLE "attribute_type_to_topic_characteristic"
(
  "topic_characteristic_id" uuid NOT NULL REFERENCES "topic_characteristic" ("id"),
  "attribute_type_id" uuid NOT NULL REFERENCES "attribute_type" ("id"),
  "multiplicity" uuid NOT NULL REFERENCES "multiplicity" ("id"),
  "default_value" uuid REFERENCES "value_list_values" ("id"),
  PRIMARY KEY ("attribute_type_id", "topic_characteristic_id")
);


-- Regelt die Zuordnung von Beziehungstypen zu Themenausprägungen.
CREATE TABLE "relationship_type_to_topic_characteristic"
(
  "topic_characteristic_id" uuid NOT NULL REFERENCES "topic_characteristic" ("id"),
  "relationship_type_id" uuid REFERENCES "relationship_type" ("id"),
  "multiplicity" uuid NOT NULL REFERENCES "multiplicity" ("id"),
  PRIMARY KEY ("relationship_type_id", "topic_characteristic_id")
);


-- Beziehungstabelle für Themeninstanzen.
-- Die Richtung der Beziehung sollte in Leserichtung erfolgen: topic_instance_1 Beziehung topic_instance_2
CREATE TABLE "topic_instance_x_topic_instance"
(
  "id" uuid NOT NULL PRIMARY KEY DEFAULT create_uuid(),
  "topic_instance_1" uuid NOT NULL REFERENCES "topic_instance" ("id"),
  "topic_instance_2" uuid NOT NULL REFERENCES "topic_instance" ("id"),
  "relationship_type_id" uuid NOT NULL REFERENCES "relationship_type" ("id"),
  CONSTRAINT ti_x_ti_unique_key UNIQUE ("topic_instance_1", "topic_instance_2")
);


-- Elternklasse für Attributwerte, welche referenzierende Elemente wie
-- Themeninstanz und Attributtyp vererbt. Die konkreten Attributwerte werden
-- in erbenden Tabellen geführt.
-- Der Datentyp des Attributwertes muss dem entsprechen, der im Datentyp des
-- zugehörigen Attributtyps spezifiziert ist.
CREATE TABLE "attribute_value"
(
  "id" uuid NOT NULL PRIMARY KEY DEFAULT create_uuid(),
  "attribute_type_id" uuid NOT NULL REFERENCES "attribute_type" ("id"),
  "topic_instance_id" uuid NOT NULL REFERENCES "topic_instance" ("id"),
  CHECK (false) NO INHERIT -- unterbindet direktes Eintragen in diese Tabelle (wird nicht vererbt)
);


-- Erbt von Attributwert. Speichert zusätzlich einen konkreten Wert
-- (Refrenz auf einen Freitext).
CREATE TABLE "attribute_value_value"
(
  "value" uuid REFERENCES "pt_free_text" ("id") NOT NULL,
  PRIMARY KEY ("id"),
  FOREIGN KEY ("attribute_type_id") REFERENCES "attribute_type" ("id"),
  FOREIGN KEY ("topic_instance_id") REFERENCES "topic_instance" ("id")
) inherits ("attribute_value");


-- Erbt von Attributwert. Speichert zusätzlich einen konkreten Wert eines
-- Wertebereiches (Refrenz auf einen Wertelistenwert).
CREATE TABLE "attribute_value__domain"
(
  "domain"  uuid REFERENCES "value_list_values" ("id") NOT NULL,
  PRIMARY KEY ("id"),
  FOREIGN KEY ("attribute_type_id") REFERENCES "attribute_type" ("id"),
  FOREIGN KEY ("topic_instance_id") REFERENCES "topic_instance" ("id")
) inherits ("attribute_value");


-- Erbt von Attributwert. Speichert zusätzlich einen 2D Geometriewert.
CREATE TABLE "attribute_value_geom"
(
  "geom" geometry(geometry, 4326) NOT NULL,
  PRIMARY KEY ("id"),
  FOREIGN KEY ("attribute_type_id") REFERENCES "attribute_type" ("id"),
  FOREIGN KEY ("topic_instance_id") REFERENCES "topic_instance" ("id")
) inherits ("attribute_value");


-- Erbt von Attributwert. Speichert zusätzlich einen 3D Geometriewert.
CREATE TABLE "attribute_value_geomz"
(
  "geom" geometry(geometryz, 4326) NOT NULL,
  PRIMARY KEY ("id"),
  FOREIGN KEY ("attribute_type_id") REFERENCES "attribute_type" ("id"),
  FOREIGN KEY ("topic_instance_id") REFERENCES "topic_instance" ("id")
) inherits ("attribute_value");