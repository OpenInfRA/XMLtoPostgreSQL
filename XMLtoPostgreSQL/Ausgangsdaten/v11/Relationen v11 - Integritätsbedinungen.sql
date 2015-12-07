SET search_path TO projektdatenbank_v11_25_03_14, public;

-------------------------------------------
-- Funktionen für Integritätsbedingungen --
-------------------------------------------
-- Funktion zur Fehlerausgabe für Trigger
CREATE OR REPLACE FUNCTION insert_violation_on_trigger()
  RETURNS "trigger" AS $$
  BEGIN
    RAISE EXCEPTION 'Integrity violation while inserting into table "%".', TG_ARGV[0];
    RETURN NULL;
  END;
  $$ LANGUAGE 'plpgsql';


-- Funktion zur Fehlerausgabe für Trigger
CREATE OR REPLACE FUNCTION update_violation_on_trigger()
  RETURNS "trigger" AS $$
  BEGIN
    RAISE EXCEPTION 'Integrity violation while updating table "%".', TG_ARGV[0];
    RETURN NULL;
  END;
  $$ LANGUAGE 'plpgsql';


-- Funktion zur Fehlerausgabe für Rules
CREATE OR REPLACE FUNCTION insert_violation_on_rule(varchar)
  RETURNS integer AS $$
  BEGIN
    RAISE EXCEPTION 'Integrity violation while inserting into table "%"', $1;
    RETURN 0;
  END;
  $$ LANGUAGE 'plpgsql';


-- Funktion zur Fehlerausgabe für Rules
CREATE OR REPLACE FUNCTION update_violation_on_rule(varchar)
  RETURNS integer AS $$
  BEGIN
    RAISE EXCEPTION 'Integrity violation while updating table "%"', $1;
    RETURN 0;
  END;
  $$ LANGUAGE 'plpgsql';


-- Funktion zur Fehlerausgabe für Rules
CREATE OR REPLACE FUNCTION delete_violation_on_rule(varchar)
  RETURNS integer AS $$
  BEGIN
    RAISE EXCEPTION 'Integrity violation while deleting a row in table "%"', $1;
    RETURN 0;
  END;
  $$ LANGUAGE 'plpgsql';


-- Ermittelt die PT_Locale_Id zu Sprachangaben
-- Parameter: Sprache (deu), Land (DE), Kodierung (UTF-8)
CREATE OR REPLACE FUNCTION get_PTLocaleId(varchar, varchar, varchar)
  RETURNS uuid AS $$
  DECLARE
    lang ALIAS FOR $1;
    country ALIAS FOR $2;
    charCode ALIAS FOR $3;
    ptLocale uuid;
  BEGIN 
    -- Einträge die keiner Sprache zugeordnet werden können, müssen bei der Anfrage separat behandelt werden
    IF country IS NULL AND lang = 'zxx' THEN
      SELECT "pt"."Id" INTO ptLocale FROM "PT_Locale" "pt", "Sprachkodierung" "s", "Zeichenkodierung" "z" WHERE
             "pt"."Sprachkodierung_Id" = "s"."Id" AND "pt"."Zeichenkodierung_Id" = "z"."Id" AND
             "s"."Sprachkodierung" = lang AND "z"."Zeichenkodierung" = charCode;
    ELSE
      SELECT "pt"."Id" INTO ptLocale FROM "PT_Locale" "pt", "Sprachkodierung" "s", "Landkodierung" "l", "Zeichenkodierung" "z" WHERE
             "pt"."Sprachkodierung_Id" = "s"."Id" AND "pt"."Landkodierung_Id" = "l"."Id" AND "pt"."Zeichenkodierung_Id" = "z"."Id" AND
             "s"."Sprachkodierung" = lang AND "l"."Landkodierung" = country AND "z"."Zeichenkodierung" = charCode;
    END IF;
    RETURN ptLocale;
  END;
  $$ LANGUAGE 'plpgsql';


-- Ermittelt den LocalizedCharacterString zu einer PT_FreeTextId und einer PT_Locale_Id
-- Parameter: PT_FreeText_Id, PT_Locale_Id
CREATE OR REPLACE FUNCTION get_LocalizedCharacterString(uuid, uuid)
  RETURNS text AS $$
    SELECT "Freitext" FROM "LocalizedCharacterString"
    WHERE
      "PT_Locale_Id" = $2 AND
      "PT_FreeText_Id" = $1;
  $$ LANGUAGE 'sql';


-- Ermittelt alle Ids für eine spezifische Werteliste
-- Parameter: Name der Werteliste, PT_Locale_Id der Werteliste
CREATE OR REPLACE FUNCTION get_IdsFromValueList(varchar, uuid)
  RETURNS uuid AS $$
    SELECT
      "wlww"."Id"
    FROM
      "WL_Werteliste" "wlw",
      "WL_WertelistenWerte" "wlww",
      "LocalizedCharacterString" "lcs"
    WHERE
      "wlw"."Name" = "lcs"."PT_FreeText_Id" AND
      "lcs"."PT_Locale_Id" = $2 AND
      "wlww"."gehoert_zu_Werteliste" = "wlw"."Id" AND
      "lcs"."Freitext" = $1
  $$ LANGUAGE 'sql';


-- Ermittelt die Id eines WertelistenWertes für eine spezifische Werteliste.
-- Parameter: WertelistenWert, Name der Werteliste
CREATE OR REPLACE FUNCTION get_ValueIdFromValueList(varchar, varchar)
  RETURNS uuid AS $$
    SELECT
      "wlww"."Id"
    FROM
      "WL_Werteliste" "wlw",
      "WL_WertelistenWerte" "wlww",
      "LocalizedCharacterString" "lcs1", -- Werteliste
      "LocalizedCharacterString" "lcs2"  -- WertelistenWert
    WHERE
      "wlw"."Name" = "lcs1"."PT_FreeText_Id" AND
      "wlww"."Name" = "lcs2"."PT_FreeText_Id" AND
      "wlww"."gehoert_zu_Werteliste" = "wlw"."Id" AND
      "lcs1"."Freitext" = $2 AND
      "lcs2"."Freitext" = $1;
  $$ LANGUAGE 'sql';


-- Ermittelt für den übergebenen Wert den zugehörigen Datentyp anhand regulärer Ausdrücke.
-- Ignoriert Leerzeichen mit denen der Wert beginnt oder endet.
-- Parameter: Wert
CREATE OR REPLACE FUNCTION return_datatype(text)
  RETURNS varchar AS $$
  DECLARE
    value ALIAS FOR $1;
  BEGIN
    -- bereinige Werte von führenden und folgenden Leerzeichen
    value := trim(both ' ' from value);
    
    -- prüfe auf Integer
    IF regexp_matches(value, '^[-+]?[0-9]+$') IS NOT NULL THEN
      RETURN 'integer';
    END IF;

    -- prüfe auf Float
    IF regexp_matches(value, '^[-+]?[0-9]*\.[0-9]+$') IS NOT NULL THEN
      RETURN 'float';
    END IF;
    
    -- prüfe auf Boolean
    IF regexp_matches(value, '^true$|^t$|^false$|^f$') IS NOT NULL THEN
      RETURN 'boolean';
    END IF;
    
    -- prüfe auf Date (neben der Angabe BC werden folgende Trennzeichen beachtet: - . , / \)
    IF regexp_matches(value, '^[0-9]+-[0-9]+-[0-9]+(\s*BC)?$|^[0-9]+\.[0-9]+\.[0-9]+(\s*BC)?$|^[0-9]+/[0-9]+/[0-9]+(\s*BC)?$|^[0-9]+\\[0-9]+\\[0-9]+(\s*BC)?$|^[0-9]+,[0-9]+,[0-9]+(\s*BC)?$') IS NOT NULL THEN
      RETURN 'date';
    END IF;
    
    -- Varchar und Text unterscheiden?
    -- sonst Text
    RETURN 'text';
  END;
  $$ LANGUAGE 'plpgsql';


-- Prüft ob der erste Wert NULL ist und gibt dann den zweiten Wert zurück, sonst den Originalwert.
CREATE OR REPLACE FUNCTION create_ReturnValue(varchar, varchar DEFAULT 'NULL')
  RETURNS varchar AS $$
  BEGIN
    IF quote_nullable($1) = 'NULL' THEN
      RETURN $2;
    ELSE
      RETURN $1;
    END IF;
  END;
  $$ LANGUAGE 'plpgsql';


-- Gibt die Einheit eines Attributwertes zurück
CREATE OR REPLACE FUNCTION return_AttUnit(uuid)
  RETURNS varchar AS $$
  DECLARE
    aw_id ALIAS FOR $1;
    value varchar;
  BEGIN
    SELECT get_LocalizedCharacterString("wlw"."Name", get_PTLocaleId('zxx', NULL, 'UTF-8')) INTO value
    FROM
      "Attributwert" "aw",
      "Attributtyp" "at",
      "WL_WertelistenWerte" "wlw"
    WHERE
      "aw"."Attributtyp_Id" = "at"."Id" AND
      "at"."Datentyp" = "wlw"."Id" AND
      "aw"."Id" = aw_id;
    RETURN create_ReturnValue(value);
  END;
  $$ LANGUAGE 'plpgsql';


-- Ermittelt ob der Textwert hinter der übergebene UUID ein gültiger Eintrag in der übergebenen Werteliste ist.
CREATE OR REPLACE FUNCTION isValid_Global(varchar, uuid)
  RETURNS boolean AS $$
  BEGIN
    IF (
    SELECT
      "wlww"."Id"
    FROM
      "WL_Werteliste" "wlw",
      "WL_WertelistenWerte" "wlww",
      "LocalizedCharacterString" "lcs1"
    WHERE
      "wlw"."Name" = "lcs1"."PT_FreeText_Id" AND
      "lcs1"."PT_Locale_Id" = get_PTLocaleId('deu', 'DE', 'UTF-8') AND
      "wlww"."gehoert_zu_Werteliste" = "wlw"."Id" AND
      "lcs1"."Freitext" = $1 AND
      "wlww"."Id" = $2
      )
    IS NULL THEN
      RETURN false;
    ELSE
      RETURN true;
    END IF;
  END;
  $$ LANGUAGE 'plpgsql';

-- Ermittelt ob der Textwert hinter der übergebene UUID eine gültige Einheit ist
CREATE OR REPLACE FUNCTION isValid_Unit(uuid)
  RETURNS boolean AS $$
  BEGIN
    RETURN isValid_Global('WL_Einheit', $1);
  END;
  $$ LANGUAGE 'plpgsql';


-- Ermittelt ob der Textwert hinter der übergebene UUID ein gültiger Datentyp ist
CREATE OR REPLACE FUNCTION isValid_DataType(uuid)
  RETURNS boolean AS $$
  BEGIN
    RETURN isValid_Global('WL_Datentyp', $1);
  END;
  $$ LANGUAGE 'plpgsql';


-- Ermittelt ob der Textwert hinter der übergebene UUID ein gültiger numerischer Datentyp ist
CREATE OR REPLACE FUNCTION isValid_numericDataType(uuid)
  RETURNS boolean AS $$
  BEGIN
    IF (
    SELECT
      "wlww"."Id"
    FROM
      "WL_Werteliste" "wlw",
      "WL_WertelistenWerte" "wlww",
      "LocalizedCharacterString" "lcs1",
      "LocalizedCharacterString" "lcs2"
    WHERE
      "wlw"."Name" = "lcs1"."PT_FreeText_Id" AND
      "wlww"."Name" = "lcs2"."PT_FreeText_Id" AND
      "lcs1"."PT_Locale_Id" = get_PTLocaleId('deu', 'DE', 'UTF-8') AND
      "lcs2"."PT_Locale_Id" = get_PTLocaleId('zxx', NULL, 'UTF-8') AND
      "wlww"."gehoert_zu_Werteliste" = "wlw"."Id" AND
      "lcs1"."Freitext" = 'WL_Datentyp' AND
      ("lcs2"."Freitext" = 'integer' OR
      "lcs2"."Freitext" = 'float') AND
      "wlww"."Id" = $1
      )
    IS NULL THEN
      RETURN false;
    ELSE
      RETURN true;
    END IF;
  END;
  $$ LANGUAGE 'plpgsql';


-- Ermittelt ob der Textwert hinter der übergebene UUID eine gültige AttributtypGruppe ist
CREATE OR REPLACE FUNCTION isValid_AttributeTypeGroup(uuid)
  RETURNS boolean AS $$
  BEGIN
    RETURN isValid_Global('WL_AttributtypGruppe', $1);
  END;
  $$ LANGUAGE 'plpgsql';


-- Ermittelt ob der Textwert hinter der übergebene UUID ein gültiges Thema ist
CREATE OR REPLACE FUNCTION isValid_Topic(uuid)
  RETURNS boolean AS $$
  BEGIN
    RETURN isValid_Global('WL_Thema', $1);
  END;
  $$ LANGUAGE 'plpgsql';


-- Ermittelt ob der Textwert hinter der übergebene UUID ein gültiger Beziehungstyp ist
CREATE OR REPLACE FUNCTION isValid_RelationShipType(uuid)
  RETURNS boolean AS $$
  BEGIN
    RETURN isValid_Global('WL_Beziehungstyp', $1);
  END;
  $$ LANGUAGE 'plpgsql';


-- Ermittelt ob der Textwert hinter der übergebene UUID ein gültiger SKOSBeziehungsart ist
CREATE OR REPLACE FUNCTION isValid_SKOSRelation(uuid)
  RETURNS boolean AS $$
  BEGIN
    RETURN isValid_Global('WL_SKOSBeziehungsart', $1);
  END;
  $$ LANGUAGE 'plpgsql';


-- Rekursive Funktion zur Überprüfung auf Schleifenerzeugung durch das Einfügen
-- der beiden übergebenen Parameter in die beiden übergebenen Listen.
-- Parameter: erste UUID, zweite UUID, Liste für die erste UUID, Liste für die zweite UUID
CREATE OR REPLACE FUNCTION check_loop_recursive(uuid, uuid, uuid[], uuid[])
  RETURNS boolean AS $$
  DECLARE
    l_start ALIAS FOR $1; -- Startwert für eine potentielle Schleife
    l_end ALIAS FOR $2;   -- Endwert für eine potentielle Schleife
    list1 ALIAS FOR $3;
    list2 ALIAS FOR $4;
    swap1 uuid[];
    swap2 uuid[];
  BEGIN
    -- prüfe ob die Listen nicht leer sind
    IF (array_length(list1, 1) IS NULL) THEN
      RETURN false;
    END IF;
    
    -- Laufe durch die Listen (Array beginnt NICHT bei Index 0) ...
    FOR i IN 1..array_length(list1, 1) LOOP
      -- ... und Suche nach dem Endwert für eine potentielle Schleife in der ersten Liste
      IF l_end = list1[i] THEN
        -- falls der Startwert einer potentiellen Schleife dem Eintrag in der zweiten Liste entspricht, wurde eine Schleife gefunden
        IF (list2[i] = l_start) THEN
          RETURN true;
        END IF;

        -- speichere den neuen Endwert für eine potentielle Schleife
        l_end := list2[i];
        
        -- entferne die eben kontrollierten Werte aus beiden Listen
        FOR x IN 1..array_length(list1, 1) LOOP
          -- wenn die Übergabeparameter ungleich den Werte in den Listen sind ...
          IF ((list1[i] != list1[x]) OR (list2[i] != list2[x])) THEN
            -- ... füge sie zu temporären Listen hinzu
            swap1 := array_append(swap1, list1[x]);
            swap2 := array_append(swap2, list2[x]);
          END IF;
        END LOOP;
        
        -- schreibe die temporären Listen in die ursprünglichen Listen zurück
        list1 := swap1;
        list2 := swap2;
        
        -- Aufruf und Abbruchbedingung der Rekursion
        IF (check_loop_recursive(l_start, l_end, list1, list2) = true) THEN
          RETURN true;
        ELSE
          RETURN false;
        END IF;
      END IF;
    END LOOP;
    -- keinen passenden Eintrag gefunden -> keine Schleife vorhanden
    RETURN false;
  END;
  $$ LANGUAGE 'plpgsql';


-- Prüft ob durch das Einfügen der beiden UUIDs keine Schleife innerhalb der übergebenen Tabelle
-- entsteht. Dies ist nur dann relevant, wenn der Eintrag die Beziehungsart "parent to" bekommen soll.
-- Wenn eine Schleife existiert, wird TRUE zurück geliefert, andernfalls FALSE.
-- Es kann nur auf folgende Tabellen angewandt werden: Attributtyp_x_Attributtyp,
-- WL_Werteliste_x_WL_Werteliste, WL_WertelistenWerte_x_WL_WertelistenWerte
-- Parameter: UUID des ersten Eintrages, UUID des zweiten Eintrages, UUID der SKOS Beziehungsart,
-- Name der Tabelle die hier verknüpft werden soll (für z. B. "Attributtyp_x_Attributtyp" -> nur
-- "Attributtyp" übergeben), UUID des ersten Updatewertes, UUID des zweiten Updatewertes
CREATE OR REPLACE FUNCTION check_loop(uuid, uuid, uuid, varchar, uuid DEFAULT NULL, uuid DEFAULT NULL)
  RETURNS boolean AS $$
  DECLARE
    l_start ALIAS FOR $1;
    l_end ALIAS FOR $2;
    relation ALIAS FOR $3;
    x_column ALIAS FOR $4;
    u_start ALIAS FOR $5;
    u_end ALIAS FOR $6;
    x_table varchar;
    relation_id uuid;
    list1 uuid[];
    list2 uuid[];
    swap1 uuid[];
    swap2 uuid[];
  BEGIN
    
    -- erzeuge _x_ Tabelle
    x_table := x_column || '_x_' || x_column;

    -- ermittle UUID für Beziehungsart "parent to"
    SELECT get_ValueIdFromValueList('parent to', 'WL_SKOSBeziehungsart') INTO relation_id;
    
    -- test ob es sich bei der übergebeben Beziehungsart nicht um "parent to" handelt und breche ggf. ab
    IF relation_id != relation THEN
      RETURN false;
    END IF;
    
    -- speichere die zu vergleichenden Elemente in einer Liste, sortiert nach demselben Wert
    EXECUTE 'SELECT array(SELECT ' || quote_ident(x_column || '_1') || ' FROM ' || quote_ident(x_table) || ' WHERE "Beziehungsart" = ' || quote_literal(relation_id) || ' ORDER BY ' || quote_ident(x_column || '_1') || ');' INTO list1;
    EXECUTE 'SELECT array(SELECT ' || quote_ident(x_column || '_2') || ' FROM ' || quote_ident(x_table) || ' WHERE "Beziehungsart" = ' || quote_literal(relation_id) || ' ORDER BY ' || quote_ident(x_column || '_1') || ');' INTO list2;
    
    -- prüfe ob ein UPDATE vorliegt
    IF (u_start IS NOT NULL) AND (u_end IS NOT NULL) THEN
      -- entferne die Elemente in den Listen, die aktualisiert werden sollen
      FOR x IN 1..array_length(list1, 1) LOOP
        -- wenn die Übergabeparameter ungleich den Werte in den Listen sind ...
        IF ((u_start != list1[x]) OR (u_end != list2[x])) THEN
          -- ... füge sie zu temporären Listen hinzu
          swap1 := array_append(swap1, list1[x]);
          swap2 := array_append(swap2, list2[x]);
        END IF;
      END LOOP;
      
      -- schreibe die temporären Listen in die ursprünglichen Listen zurück
      list1 := swap1;
      list2 := swap2;
    END IF;
    
    -- Rufe die rekursive Funktion auf und prüfe auf Schleifen
    IF check_loop_recursive(l_start, l_end, list1, list2) = false THEN
      -- keine Schleife vorhanden
      RETURN false;
    ELSE
      -- Schleife vorhanden
      RETURN true;
    END IF;
    
  END;
  $$ LANGUAGE 'plpgsql';


-------------------------------------
-- komplexe Integritätsbedingungen --
-------------------------------------

-- Integritätsbedingungen für die Relation "Multiplizitaet"
-- (1) Der "Min-Wert" der Relation "Multiplizitaet" muss >= 0 sein.
-- (2) Der "Max-Wert" der Relation "Multiplizitaet" muss > 0 sein.
-- (3) Der "Max-Wert" der Relation "Multiplizitaet" muss >= dem "Min-Wert" sein.
/*
CREATE TRIGGER Multiplizitaet_Insert
BEFORE INSERT ON "Multiplizitaet"
  FOR EACH ROW
    WHEN (NEW."Min-Wert" < 0 OR NEW."Max-Wert" <= 0 OR NEW."Min-Wert" > NEW."Max-Wert")
EXECUTE PROCEDURE insert_violation_on_trigger('Multiplizitaet');

CREATE TRIGGER Multiplizitaet_Update
BEFORE UPDATE ON "Multiplizitaet"
  FOR EACH ROW
    WHEN (NEW."Min-Wert" < 0 OR NEW."Max-Wert" <= 0 OR NEW."Min-Wert" > NEW."Max-Wert" OR OLD."Min-Wert" > NEW."Max-Wert" OR NEW."Min-Wert" > OLD."Max-Wert")
EXECUTE PROCEDURE update_violation_on_trigger('Multiplizitaet');



-- (4) Die Spalte "Sprachkodierung" der Relation "Sprachkodierung" muss genau 3 Zeichen beinhalten.
CREATE TRIGGER Sprachkodierung_Insert
BEFORE INSERT ON "Sprachkodierung"
  FOR EACH ROW
    WHEN (char_length(NEW."Sprachkodierung") <> 3 )
EXECUTE PROCEDURE insert_violation_on_trigger('Sprachkodierung');

CREATE TRIGGER Sprachkodierung_Update
BEFORE UPDATE ON "Sprachkodierung"
  FOR EACH ROW
    WHEN (char_length(NEW."Sprachkodierung") <> 3 )
EXECUTE PROCEDURE update_violation_on_trigger('Sprachkodierung');


-- (5) Die Spalte "Landkodierung" der Relation "Landkodierung" muss genau 2 Zeichen beinhalten.
CREATE TRIGGER Landkodierung_Insert
BEFORE INSERT ON "Landkodierung"
  FOR EACH ROW
    WHEN (char_length(NEW."Landkodierung") <> 2 )
EXECUTE PROCEDURE insert_violation_on_trigger('Landkodierung');

CREATE TRIGGER Landkodierung_Update
BEFORE UPDATE ON "Landkodierung"
  FOR EACH ROW
    WHEN (char_length(NEW."Landkodierung") <> 2 )
EXECUTE PROCEDURE update_violation_on_trigger('Landkodierung');



-- Integritätsbedingungen für die Relation "Attributtyp"
CREATE OR REPLACE RULE Attributtyp_Insert AS ON INSERT TO "Attributtyp"
  WHERE (
    -- (6) Die Spalte "Einheit" der Relation "Attributtyp" darf ausschließlich Werte aus "WL_WertelistenWerte" zugeordnet bekommen, welche sich in der Werteliste "WL_Einheit" befinden.
    (NEW."Einheit" IS NOT NULL AND NOT isValid_unit(NEW."Einheit"))
    OR
    -- (7) Die Spalte "Datentyp" der Relation "Attributtyp" muss entweder Float oder Integer zugeordnet bekommen, insofern eine Einheit vorhanden ist.
    (NEW."Einheit" IS NOT NULL AND NOT isValid_numericDataType(NEW."Datentyp"))
    OR
    -- (8) Die Spalte "Datentyp" der Relation "Attributtyp" darf ausschließlich Werte aus "WL_WertelistenWerte" zugeordnet bekommen, welche sich in der Werteliste  "WL_Datentyp" befinden.
    (isValid_DataType(NEW."Datentyp") IS FALSE)
    OR
    -- (9) Die Spalte "Wertebereich" der Relation "Attributtyp" darf ausschließlich Werte aus "WL_Werteliste" zugeordnet bekommen, welche nicht "WL_AttributtypGruppe", "WL_Beziehungstyp", "WL_Datentyp", "WL_Einheit", "WL_SKOSBeziehungsart" oder "WL_Thema" entsprechen.
    NEW."Wertebereich" IS NOT NULL AND NEW."Wertebereich" IN (
    SELECT
      "wlw"."Id"
    FROM
      "WL_Werteliste" "wlw",
      "LocalizedCharacterString" "lcs"
    WHERE
      "wlw"."Name" = "lcs"."PT_FreeText_Id" AND
      "lcs"."PT_Locale_Id" = get_PTLocaleId('deu', 'DE', 'UTF-8') AND
      ("lcs"."Freitext" = 'WL_Einheit' OR
       "lcs"."Freitext" = 'WL_Datentyp' OR
       "lcs"."Freitext" = 'WL_Thema' OR
       "lcs"."Freitext" = 'WL_AttributtypGruppe' OR
       "lcs"."Freitext" = 'WL_Beziehungstyp' OR
       "lcs"."Freitext" = 'WL_SKOSBeziehungsart')
    )
  )
  DO INSTEAD (SELECT insert_violation_on_rule('Attributtyp'));

CREATE OR REPLACE RULE Attributtyp_Update AS ON UPDATE TO "Attributtyp"
  WHERE (
    -- (6) Die Spalte "Einheit" der Relation "Attributtyp" darf ausschließlich Werte aus "WL_WertelistenWerte" zugeordnet bekommen, welche sich in der Werteliste "WL_Einheit" befinden.
    (NEW."Einheit" IS NOT NULL AND NOT isValid_unit(NEW."Einheit"))
    OR
    -- (7) Die Spalte "Datentyp" der Relation "Attributtyp" muss entweder Float oder Integer zugeordnet bekommen, insofern eine Einheit vorhanden ist.
    (NEW."Einheit" IS NOT NULL AND NOT isValid_numericDataType(NEW."Datentyp"))
    OR
    -- (8) Die Spalte "Datentyp" der Relation "Attributtyp" darf ausschließlich Werte aus "WL_WertelistenWerte" zugeordnet bekommen, welche sich in der Werteliste  "WL_Datentyp" befinden.
    (isValid_DataType(NEW."Datentyp") IS FALSE)
    OR
    -- (9) Die Spalte "Wertebereich" der Relation "Attributtyp" darf ausschließlich Werte aus "WL_Werteliste" zugeordnet bekommen, welche nicht "WL_AttributtypGruppe", "WL_Beziehungstyp", "WL_Datentyp", "WL_Einheit", "WL_SKOSBeziehungsart" oder "WL_Thema" entsprechen.
    NEW."Wertebereich" IS NOT NULL AND NEW."Wertebereich" IN (
    SELECT
      "wlw"."Id"
    FROM
      "WL_Werteliste" "wlw",
      "LocalizedCharacterString" "lcs"
    WHERE
      "wlw"."Name" = "lcs"."PT_FreeText_Id" AND
      "lcs"."PT_Locale_Id" = get_PTLocaleId('deu', 'DE', 'UTF-8') AND
      ("lcs"."Freitext" = 'WL_Einheit' OR
       "lcs"."Freitext" = 'WL_Datentyp' OR
       "lcs"."Freitext" = 'WL_Thema' OR
       "lcs"."Freitext" = 'WL_AttributtypGruppe' OR
       "lcs"."Freitext" = 'WL_Beziehungstyp' OR
       "lcs"."Freitext" = 'WL_SKOSBeziehungsart')
    )
  )
  DO INSTEAD (SELECT update_violation_on_rule('Attributtyp'));



-- Integritätsbedingungen für die Relation "Attributtyp_x_Attributtyp_Gruppe"
CREATE OR REPLACE RULE Attributtyp_x_Attributtyp_Gruppe_Insert AS ON INSERT TO "Attributtyp_x_Attributtyp_Gruppe"
  WHERE (
    -- (10) Die Spalte "Attributtyp_Gruppe" der Relation "Attributtyp_x_Attributtyp_Gruppe" darf ausschließlich Werte aus "WL_WertelistenWerte" zugeordnet bekommen, welche sich in der Werteliste "WL_AttributtypGruppe" befinden
    NOT isValid_AttributeTypeGroup(NEW."Attributtyp_Gruppe")
  )
  DO INSTEAD (SELECT insert_violation_on_rule('Attributtyp_x_Attributtyp_Gruppe'));

CREATE OR REPLACE RULE Attributtyp_x_Attributtyp_Gruppe_Update AS ON UPDATE TO "Attributtyp_x_Attributtyp_Gruppe"
  WHERE (
    -- (10) Die Spalte "Attributtyp_Gruppe" der Relation "Attributtyp_x_Attributtyp_Gruppe" darf ausschließlich Werte aus "WL_WertelistenWerte" zugeordnet bekommen, welche sich in der Werteliste "WL_AttributtypGruppe" befinden
    NOT isValid_AttributeTypeGroup(NEW."Attributtyp_Gruppe")
  )
  DO INSTEAD (SELECT update_violation_on_rule('Attributtyp_x_Attributtyp_Gruppe'));



-- Integritätsbedingungen für die Relation "Attributtypen_zur_Themenauspraegung"
-- (11) Die Spalte "Standardwert" der Relation "Attributtypen_zur_Themenauspraegung" darf nur dann einen Eintrag besitzen, wenn das Attribut "Wertebereich" der zugehörigen Relation "Attributtyp" ebenfalls einen Eintrag hat. Wenn beide Attribute nicht NULL sind, dann muss der Wert von "WL_Werteliste", der den beiden Einträgen in "WL_WertelistenWerte" zugeordnet ist, identisch sein.
-- CREATE ...



-- Integritätsbedingungen für die Relation "Beziehungstyp"
CREATE OR REPLACE RULE Beziehungstyp_Insert AS ON INSERT TO "Beziehungstyp"
  WHERE (
    -- (12) Die Spalte "Referenz_auf" der Relation "Beziehungstyp" darf ausschließlich Werte aus "WL_WertelistenWerte" zugeordnet bekommen, bei denen der zugehörige Wert aus "WL_Werteliste" den Wert "WL_Thema" hat.
    NOT isValid_Topic(NEW."Referenz_auf")
    OR
    -- (13) Die Spalte "Beschreibung" der Relation "Beziehungstyp" darf ausschließlich Werte aus "WL_WertelistenWerte" zugeordnet bekommen, welche sich in der Werteliste "WL_Beziehungstyp" befinden.
    NOT isValid_RelationShipType(NEW."Beschreibung")
  )
  DO INSTEAD (SELECT insert_violation_on_rule('Beziehungstyp'));

CREATE OR REPLACE RULE Beziehungstyp_Update AS ON UPDATE TO "Beziehungstyp"
  WHERE (
    -- (12) Die Spalte "Referenz_auf" der Relation "Beziehungstyp" darf ausschließlich Werte aus "WL_WertelistenWerte" zugeordnet bekommen, bei denen der zugehörige Wert aus "WL_Werteliste" den Wert "WL_Thema" hat.
    NOT isValid_Topic(NEW."Referenz_auf")
    OR
    -- (13) Die Spalte "Beschreibung" der Relation "Beziehungstyp" darf ausschließlich Werte aus "WL_WertelistenWerte" zugeordnet bekommen, welche sich in der Werteliste "WL_Beziehungstyp" befinden.
    NOT isValid_RelationShipType(NEW."Beschreibung")
  )
  DO INSTEAD (SELECT update_violation_on_rule('Beziehungstyp'));



-- Integritätsbedingungen für die Relation "Themenauspraegung"
CREATE OR REPLACE RULE Themenauspraegung_Insert AS ON INSERT TO "Themenauspraegung"
  WHERE (
    -- (14) Die Spalte "Thema" der Relation "Themenauspraegung" darf ausschließlich Werte aus "WL_WertelistenWerte" zugeordnet bekommen, welche sich in der Werteliste "WL_Thema" befinden.
    NOT isValid_Topic(NEW."Thema")
  )
  DO INSTEAD (SELECT insert_violation_on_rule('Themenauspraegung'));

CREATE OR REPLACE RULE Themenauspraegung_Update AS ON UPDATE TO "Themenauspraegung"
  WHERE (
    -- (14) Die Spalte "Thema" der Relation "Themenauspraegung" darf ausschließlich Werte aus "WL_WertelistenWerte" zugeordnet bekommen, welche sich in der Werteliste "WL_Thema" befinden.
    NOT isValid_Topic(NEW."Thema")
  )
  DO INSTEAD (SELECT update_violation_on_rule('Themenauspraegung'));



-- Integritätsbedingungen für die Relation "WL_Werteliste_x_WL_Werteliste"
CREATE OR REPLACE RULE WL_Werteliste_x_WL_Werteliste_Insert AS ON INSERT TO "WL_Werteliste_x_WL_Werteliste"
  WHERE (
    -- (15) Die Spalte "Beziehungsart" der Relation "WL_Werteliste_x_WL_Werteliste" darf ausschließlich Werte aus "WL_WertelistenWerte" zugeordnet bekommen, welche sich in der Werteliste "WL_SKOSBeziehungsart" befinden.
    NOT isValid_SKOSRelation(NEW."Beziehungsart")
    OR
    -- (16) Wenn in der Relation "WL_Werteliste_x_WL_Werteliste" ein Tupel den Wert "parent to" in der Spalte "Beziehungsart" besitzt, darf dieselbe Attributtypenkombination nicht invertiert mit der "Beziehungsart" "parent_to" auftreten.
    true IN (SELECT ROW(NEW."WL_Werteliste_2", NEW."WL_Werteliste_1") = 
          ROW(
            "wxw"."WL_Werteliste_1",
            "wxw"."WL_Werteliste_2")
          FROM
            "WL_WertelistenWerte" "wlw",
            "WL_Werteliste_x_WL_Werteliste" "wxw",
            "LocalizedCharacterString" "lcs"
          WHERE
            "wxw"."Beziehungsart" = "wlw"."Id" AND
            "wlw"."Name" = "lcs"."PT_FreeText_Id" AND
            "lcs"."Freitext" = 'parent to'
          )
    OR
    -- (17) Wenn in der Relation "WL_Werteliste_x_WL_Werteliste" ein Tupel den Wert "parent_to" in der Spalte "Beziehungsart" besitzt, darf es keine Schleife über n Einträge geben.
    (SELECT check_loop(NEW."WL_Werteliste_1", NEW."WL_Werteliste_2", NEW."Beziehungsart", 'WL_Werteliste'))
    OR
    -- (18) Die Spalten "WL_Werteliste_1" und "WL_Werteliste_2" der Relation "WL_Werteliste_x_WL_Werteliste" dürfen in einem Tupel nicht denselben Wert besitzen.
    NEW."WL_Werteliste_1" = NEW."WL_Werteliste_2"
  )
  DO INSTEAD (SELECT insert_violation_on_rule('WL_Werteliste_x_WL_Werteliste'));

CREATE OR REPLACE RULE WL_Werteliste_x_WL_Werteliste_Update AS ON UPDATE TO "WL_Werteliste_x_WL_Werteliste"
  WHERE (
    -- (15) Die Spalte "Beziehungsart" der Relation "WL_Werteliste_x_WL_Werteliste" darf ausschließlich Werte aus "WL_WertelistenWerte" zugeordnet bekommen, welche sich in der Werteliste "WL_SKOSBeziehungsart" befinden.
    NOT isValid_SKOSRelation(NEW."Beziehungsart")
    OR
    -- (16) Wenn in der Relation "WL_Werteliste_x_WL_Werteliste" ein Tupel den Wert "parent to" in der Spalte "Beziehungsart" besitzt, darf dieselbe Attributtypenkombination nicht invertiert mit der "Beziehungsart" "parent_to" auftreten.
    true IN (SELECT ROW(NEW."WL_Werteliste_2", NEW."WL_Werteliste_1") = 
          ROW(
            "wxw"."WL_Werteliste_1",
            "wxw"."WL_Werteliste_2")
          FROM
            "WL_WertelistenWerte" "wlw",
            "WL_Werteliste_x_WL_Werteliste" "wxw",
            "LocalizedCharacterString" "lcs"
          WHERE
            "wxw"."Beziehungsart" = "wlw"."Id" AND
            "wlw"."Name" = "lcs"."PT_FreeText_Id" AND
            "lcs"."Freitext" = 'parent to'
          )
    OR
    -- (17) Wenn in der Relation "WL_Werteliste_x_WL_Werteliste" ein Tupel den Wert "parent_to" in der Spalte "Beziehungsart" besitzt, darf es keine Schleife über n Einträge geben.
    (SELECT check_loop(NEW."WL_Werteliste_1", NEW."WL_Werteliste_2", NEW."Beziehungsart", 'WL_Werteliste', OLD."WL_Werteliste_1", OLD."WL_Werteliste_2"))
    OR
    -- (18) Die Spalten "WL_Werteliste_1" und "WL_Werteliste_2" der Relation "WL_Werteliste_x_WL_Werteliste" dürfen in einem Tupel nicht denselben Wert besitzen.
    ((NEW."WL_Werteliste_1" = NEW."WL_Werteliste_2") OR (NEW."WL_Werteliste_1" = OLD."WL_Werteliste_2") OR (OLD."WL_Werteliste_1" = NEW."WL_Werteliste_2"))
  )
  DO INSTEAD (SELECT update_violation_on_rule('WL_Werteliste_x_WL_Werteliste'));



-- Integritätsbedingungen für die Relation "WL_WertelistenWerte_x_WL_WertelistenWerte"
CREATE OR REPLACE RULE WL_WertelistenWerte_x_WL_WertelistenWerte_Insert AS ON INSERT TO "WL_WertelistenWerte_x_WL_WertelistenWerte"
  WHERE (
    -- (19) Die Spalte "Beziehungsart" der Relation "WL_WertelistenWerte_x_WL_WertelistenWerte" darf ausschließlich Werte aus "WL_WertelistenWerte" zugeordnet bekommen, welche sich in der Werteliste "WL_SKOSBeziehungsart" befinden.
    NOT isValid_SKOSRelation(NEW."Beziehungsart")
    OR
    -- (20) Wenn in der Relation "WL_WertelistenWerte_x_WL_WertelistenWerte" ein Tupel den Wert "parent to" in der Spalte "Beziehungsart" besitzt, darf dieselbe Attributtypenkombination nicht invertiert mit der "Beziehungsart" "parent to" auftreten.
    true IN (SELECT ROW(NEW."WL_WertelistenWerte_2", NEW."WL_WertelistenWerte_1") = 
          ROW(
            "wxw"."WL_WertelistenWerte_1",
            "wxw"."WL_WertelistenWerte_2")
          FROM
            "WL_WertelistenWerte" "wlw",
            "WL_WertelistenWerte_x_WL_WertelistenWerte" "wxw",
            "LocalizedCharacterString" "lcs"
          WHERE
            "wxw"."Beziehungsart" = "wlw"."Id" AND
            "wlw"."Name" = "lcs"."PT_FreeText_Id" AND
            "lcs"."Freitext" = 'parent to'
          )
    OR
    -- (21) Wenn in der Relation "WL_WertelistenWerte_x_WL_WertelistenWerte" ein Tupel den Wert "parent to" in der Spalte "Beziehungsart" besitzt, darf es keine Schleife über n Einträge geben.
    (SELECT check_loop(NEW."WL_WertelistenWerte_1", NEW."WL_WertelistenWerte_2", NEW."Beziehungsart", 'WL_WertelistenWerte'))
    OR
    -- (22) Die Spalten "WL_WertelistenWerte_1" und "WL_WertelistenWerte_2" der Relation "WL_WertelistenWerte_x_WL_WertelistenWerte" dürfen in einem Tupel nicht denselben Wert besitzen.
    NEW."WL_WertelistenWerte_1" = NEW."WL_WertelistenWerte_2"
  )
  DO INSTEAD (SELECT insert_violation_on_rule('WL_WertelistenWerte_x_WL_WertelistenWerte'));

CREATE OR REPLACE RULE WL_WertelistenWerte_x_WL_WertelistenWerte_Update AS ON UPDATE TO "WL_WertelistenWerte_x_WL_WertelistenWerte"
  WHERE (
    -- (19) Die Spalte "Beziehungsart" der Relation "WL_WertelistenWerte_x_WL_WertelistenWerte" darf ausschließlich Werte aus "WL_WertelistenWerte" zugeordnet bekommen, welche sich in der Werteliste "WL_SKOSBeziehungsart" befinden.
    NOT isValid_SKOSRelation(NEW."Beziehungsart")
    OR
    -- (20) Wenn in der Relation "WL_WertelistenWerte_x_WL_WertelistenWerte" ein Tupel den Wert "parent to" in der Spalte "Beziehungsart" besitzt, darf dieselbe Attributtypenkombination nicht invertiert mit der "Beziehungsart" "parent to" auftreten.
    true IN (SELECT ROW(NEW."WL_WertelistenWerte_2", NEW."WL_WertelistenWerte_1") = 
          ROW(
            "wxw"."WL_WertelistenWerte_1",
            "wxw"."WL_WertelistenWerte_2")
          FROM
            "WL_WertelistenWerte" "wlw",
            "WL_WertelistenWerte_x_WL_WertelistenWerte" "wxw",
            "LocalizedCharacterString" "lcs"
          WHERE
            "wxw"."Beziehungsart" = "wlw"."Id" AND
            "wlw"."Name" = "lcs"."PT_FreeText_Id" AND
            "lcs"."Freitext" = 'parent to'
          )
    OR
    -- (21) Wenn in der Relation "WL_WertelistenWerte_x_WL_WertelistenWerte" ein Tupel den Wert "parent to" in der Spalte "Beziehungsart" besitzt, darf es keine Schleife über n Einträge geben.
    (SELECT check_loop(NEW."WL_WertelistenWerte_1", NEW."WL_WertelistenWerte_2", NEW."Beziehungsart", 'WL_WertelistenWerte', OLD."WL_WertelistenWerte_1", OLD."WL_WertelistenWerte_2"))
    OR
    -- (22) Die Spalten "WL_WertelistenWerte_1" und "WL_WertelistenWerte_2" der Relation "WL_WertelistenWerte_x_WL_WertelistenWerte" dürfen in einem Tupel nicht denselben Wert besitzen.
    ((NEW."WL_WertelistenWerte_1" = NEW."WL_WertelistenWerte_2") OR (NEW."WL_WertelistenWerte_1" = OLD."WL_WertelistenWerte_2") OR (OLD."WL_WertelistenWerte_1" = NEW."WL_WertelistenWerte_2"))
  )
  DO INSTEAD (SELECT update_violation_on_rule('WL_WertelistenWerte_x_WL_WertelistenWerte'));



-- Integritätsbedingungen für die Relation "Attributtyp_x_Attributtyp"
CREATE OR REPLACE RULE Attributtyp_x_Attributtyp_Insert AS ON INSERT TO "Attributtyp_x_Attributtyp"
  WHERE (
    -- (23) Die Spalte "Beziehungsart" der Relation "Attributtyp_x_Attributtyp" darf ausschließlich Werte aus "WL_WertelistenWerte" zugeordnet bekommen, welche sich in der Werteliste "WL_SKOSBeziehungsart" befinden.
    NOT isValid_SKOSRelation(NEW."Beziehungsart")
    OR
    -- (24) Wenn in der Relation "Attributtyp_x_Attributtyp" ein Tupel den Wert "parent to" in der Spalte "Beziehungsart" besitzt, darf dieselbe Attributtypenkombination nicht invertiert mit der "Beziehungsart" "parent to" auftreten.
    true IN (SELECT ROW(NEW."Attributtyp_2", NEW."Attributtyp_1") = 
          ROW(
            "axa"."Attributtyp_1",
            "axa"."Attributtyp_2")
          FROM
            "WL_WertelistenWerte" "wlw",
            "Attributtyp_x_Attributtyp" "axa",
            "LocalizedCharacterString" "lcs"
          WHERE
            "axa"."Beziehungsart" = "wlw"."Id" AND
            "wlw"."Name" = "lcs"."PT_FreeText_Id" AND
            "lcs"."Freitext" = 'parent to'
          )
    OR
    -- (25) Wenn in der Relation "Attributtyp_x_Attributtyp" ein Tupel den Wert "parent to" in der Spalte "Beziehungsart" besitzt, darf es keine Schleife über n Einträge geben.
    (SELECT check_loop(NEW."Attributtyp_1", NEW."Attributtyp_2", NEW."Beziehungsart", 'Attributtyp'))
    OR
    -- (26) Die Spalten "Attributtyp_1" und "Attributtyp_2" der Relation "Attributtyp_x_Attributtyp" dürfen in einem Tupel nicht denselben Wert besitzen.
    NEW."Attributtyp_1" = NEW."Attributtyp_2"
  )
  DO INSTEAD (SELECT insert_violation_on_rule('Attributtyp_x_Attributtyp'));

CREATE OR REPLACE RULE Attributtyp_x_Attributtyp_Update AS ON UPDATE TO "Attributtyp_x_Attributtyp"
  WHERE (
    -- (23) Die Spalte "Beziehungsart" der Relation "Attributtyp_x_Attributtyp" darf ausschließlich Werte aus "WL_WertelistenWerte" zugeordnet bekommen, welche sich in der Werteliste "WL_SKOSBeziehungsart" befinden.
    NEW."Beziehungsart" NOT IN (get_IdsFromValueList('WL_SKOSBeziehungsart', get_PTLocaleId('deu', 'DE', 'UTF-8')))
    OR
    -- (24) Wenn in der Relation "Attributtyp_x_Attributtyp" ein Tupel den Wert "parent to" in der Spalte "Beziehungsart" besitzt, darf dieselbe Attributtypenkombination nicht invertiert mit der "Beziehungsart" "parent to" auftreten.
    true IN (SELECT ROW(NEW."Attributtyp_2", NEW."Attributtyp_1") = 
          ROW(
            "axa"."Attributtyp_1",
            "axa"."Attributtyp_2")
          FROM
            "WL_WertelistenWerte" "wlw",
            "Attributtyp_x_Attributtyp" "axa",
            "LocalizedCharacterString" "lcs"
          WHERE
            "axa"."Beziehungsart" = "wlw"."Id" AND
            "wlw"."Name" = "lcs"."PT_FreeText_Id" AND
            "lcs"."Freitext" = 'parent to'
	  )
    OR
    -- (25) Wenn in der Relation "Attributtyp_x_Attributtyp" ein Tupel den Wert "parent to" in der Spalte "Beziehungsart" besitzt, darf es keine Schleife über n Einträge geben.
    ((NEW."Attributtyp_1" = NEW."Attributtyp_2") OR (NEW."Attributtyp_1" = OLD."Attributtyp_2") OR (OLD."Attributtyp_1" = NEW."Attributtyp_2"))
    OR
    -- (26) Die Spalten "Attributtyp_1" und "Attributtyp_2" der Relation "Attributtyp_x_Attributtyp" dürfen in einem Tupel nicht denselben Wert besitzen.
    ((NEW."Attributtyp_1" = NEW."Attributtyp_2") OR (NEW."Attributtyp_1" = OLD."Attributtyp_2") OR (OLD."Attributtyp_1" = NEW."Attributtyp_2"))
  )
  DO INSTEAD (SELECT update_violation_on_rule('Attributtyp_x_Attributtyp'));



-- (27) Die Spalten "Themeninstanz_1" und "Themeninstanz_2" der Relation "Themeninstanz_x_Themeninstanz" dürfen in einem Tupel nicht denselben Wert besitzen.
CREATE TRIGGER Themeninstanz_x_Themeninstanz_Insert
BEFORE INSERT ON "Themeninstanz_x_Themeninstanz"
  FOR EACH ROW
    WHEN (NEW."Themeninstanz_1" = NEW."Themeninstanz_2")
EXECUTE PROCEDURE insert_violation_on_trigger('Themeninstanz_x_Themeninstanz');

CREATE TRIGGER Themeninstanz_x_Themeninstanz_Update
BEFORE UPDATE ON "Themeninstanz_x_Themeninstanz"
  FOR EACH ROW
    WHEN (
      (NEW."Themeninstanz_1" = NEW."Themeninstanz_2")
      OR
      ((NEW."Themeninstanz_1" = OLD."Themeninstanz_2") AND (NEW."Themeninstanz_2" = OLD."Themeninstanz_2"))
      OR
      ((OLD."Themeninstanz_1" = NEW."Themeninstanz_2") AND (NEW."Themeninstanz_1" = OLD."Themeninstanz_1"))
    )
EXECUTE PROCEDURE update_violation_on_trigger('Themeninstanz_x_Themeninstanz');

-- Integritätsbedingungen für die Relation "Projekt"
CREATE OR REPLACE RULE Projekt_Insert AS ON INSERT TO "Projekt"
  WHERE (
    -- (37) Es muss genau ein Tupel der Relation "Projekt" keine Beziehung zu einem anderen Tupel der Relation "Projekt" besitzen.
    -- & (38) Ein Tupel der Relation "Projekt" muss, unter Beachtung der vorangegangen Integritätsbedingung eine Beziehung zu genau einem anderen Relationstupel besitzen.
    NEW."Teilprojekt_von" IS NULL AND (SELECT count("Id") FROM "Projekt" WHERE "Teilprojekt_von" IS NULL) != 0
    OR
    NEW."Teilprojekt_von" IS NOT NULL AND (SELECT count("Id") FROM "Projekt" WHERE "Teilprojekt_von" IS NULL) != 1
    OR
    
    
    
    -- (39) Ein Tupel der Relation "Projekt" darf keine Beziehung zu sich selbst besitzen.
    -- Integritätsbedingung kann durch INSERT nicht verletzt werden (wird bereits vom DBMS abgefangen)
  )
  DO INSTEAD (SELECT insert_violation_on_rule('Projekt'));

CREATE OR REPLACE RULE Projekt_Update AS ON UPDATE TO "Projekt"
  WHERE (
    -- (37) Es muss genau ein Tupel der Relation "Projekt" keine Beziehung zu einem anderen Tupel der Relation "Projekt" besitzen.
    -- & (38) Ein Tupel der Relation "Projekt" muss, unter Beachtung der vorangegangen Integritätsbedingung eine Beziehung zu genau einem anderen Relationstupel besitzen.
    NEW."Teilprojekt_von" IS NULL AND (SELECT count("Id") FROM "Projekt" WHERE "Teilprojekt_von" IS NULL) != 0
    OR
    NEW."Teilprojekt_von" IS NOT NULL AND (SELECT count("Id") FROM "Projekt" WHERE "Teilprojekt_von" IS NULL) != 1
    OR
    -- (39) Ein Tupel der Relation "Projekt" darf keine Beziehung zu sich selbst besitzen.
    ((NEW."Teilprojekt_von" = NEW."Id") OR (OLD."Teilprojekt_von" = NEW."Id") OR (NEW."Teilprojekt_von" = OLD."Id"))
  )
  DO INSTEAD (SELECT update_violation_on_rule('Projekt'));

CREATE OR REPLACE RULE Projekt_Delete AS ON DELETE TO "Projekt"
  WHERE (
    -- (37) Es muss genau ein Tupel der Relation "Projekt" keine Beziehung zu einem anderen Tupel der Relation "Projekt" besitzen.
    -- & (38) Ein Tupel der Relation "Projekt" muss, unter Beachtung der vorangegangen Integritätsbedingung eine Beziehung zu genau einem anderen Relationstupel besitzen.
    OLD."Id" = (SELECT "Id" FROM "Projekt" WHERE "Teilprojekt_von" IS NULL)
  )
  DO INSTEAD (SELECT delete_violation_on_rule('Projekt'));
*/

/*
CREATE OR REPLACE RULE Attributwert_Insert AS ON INSERT TO "Attributwert"
  WHERE ( -- wenn der Ausdruck der Klammer TRUE ist, wird INSTEAD ausgeführt
    -- Der "Datentyp" von "Attributwert" muss dem entsprechen, der im Attribut „Datentyp“ des zugehörigen Attributtyps spezifiziert ist.
    -- ...
    -- OR
    -- Die Spalte "Geometrie" (FK auf "Geometrie_3d_SRID_0") in der Relation "Attributwert" muss genau dann einen Eintrag haben, wenn der Datentyp des zugehörigen Attributtyps "Geometry" ist.
    NEW."Geometrie_Id" IS NOT NULL AND
    return_attunit(NEW."Attributtyp_Id") NOT LIKE 'geometry'
  )
  DO INSTEAD (SELECT insert_violation_on_rule('Attributwert'));
*/
