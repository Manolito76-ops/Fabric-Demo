CREATE   PROCEDURE util.sp_Update_IngestionDateTime
    -- =========================================================================
    -- EINGABEPARAMETER
    -- =========================================================================
    @SchemaName VARCHAR(128),  -- Name des Schemas (z. B. 'stg', 'bronze')
    @TableName VARCHAR(128)   -- Name der Zieltabelle (z. B. 'orders', 'customers')
AS
BEGIN
    -- Verhindert, dass T-SQL nach jedem Befehl "X Zeilen betroffen" als 
    -- Rückmeldung sendet. Das spart Netzwerk-Overhead und verbessert die Performance.
    SET NOCOUNT ON;

    -- =========================================================================
    -- SCHRITT 1: UDF-Umgang zur Fehlervermeidung (Fabric / Synapse Workaround)
    -- =========================================================================
    -- Da Fabric den direkten Aufruf von Skalarfunktionen (UDFs) in UPDATE-
    -- Befehlen blockiert (Fehler Msg 19835), rufen wir die Funktion einmalig 
    -- vorab auf und speichern das Ergebnis in einer lokalen Variable.
    DECLARE @CurrentTime DATETIME2;
    SET @CurrentTime = util.fn_GetIngestionTime();


    -- =========================================================================
    -- SCHRITT 2: Dynamischen SQL-String deklarieren
    -- =========================================================================
    -- NVARCHAR(MAX) wird benötigt, da sp_executesql Unicode-Strings voraussetzt.
    DECLARE @SQL NVARCHAR(MAX);


    -- =========================================================================
    -- SCHRITT 3: SQL-Befehl dynamisch zusammenbauen
    -- =========================================================================
    -- QUOTENAME() umschließt Schemata und Tabellennamen mit eckigen Klammern [ ].
    -- Das verhindert SQL-Injection und erlaubt Sonder- oder Reservierte Zeichen.
    -- @TimeValue fungiert als Platzhalter (Parameter) innerhalb des dynamischen Strings.
    SET @SQL = N'
        UPDATE ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName) + N'
        SET IngestionDateTime = @TimeValue
        WHERE IngestionDateTime IS NULL;
    ';


    -- =========================================================================
    -- SCHRITT 4: Dynamisches SQL sicher ausführen
    -- =========================================================================
    -- sp_executesql führt den zusammengesetzten String aus.
    -- 1. Argument (@stmt):   Der zusammengestellte SQL-Code
    -- 2. Argument (@params): Definition aller Parameter, die im SQL-String vorkommen
    -- 3. Argument:           Übergabe der lokalen Variable @CurrentTime an den Parameter @TimeValue
    EXEC sp_executesql 
        @stmt = @SQL, 
        @params = N'@TimeValue DATETIME2', 
        @TimeValue = @CurrentTime;

END;