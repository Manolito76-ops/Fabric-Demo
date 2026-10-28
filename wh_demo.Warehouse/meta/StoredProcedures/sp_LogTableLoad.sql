CREATE   PROCEDURE [meta].[sp_LogTableLoad]
    @ExecutionID     VARCHAR(36),
    @TargetSchema    VARCHAR(50),
    @TargetTable     VARCHAR(100),
    @LoadType        VARCHAR(20),       -- z.B. 'FULL', 'DELTA'
    @RowsAffected    BIGINT = NULL,     -- Bei NULL wird im Erfolg automatisch gezählt
    @StartTime       DATETIME2(6) = NULL,
    @EndTime         DATETIME2(6) = NULL,
    @Status          VARCHAR(20),       -- 'SUCCESS' oder 'FAILED'
    @ErrorMessage    VARCHAR(MAX) = NULL,
    @UpdateIngestionColumn BIT = 1      -- 1 = IngestionDate in Zieltabelle updaten
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentTime DATETIME2(6);

    -- 1. Zeitstempel über die gekapselte Utility-Procedure holen
    EXEC [util].[sp_GetIngestionTime] @IngestionTime = @CurrentTime OUTPUT;

    -- Falls Zeiten nicht aus der Pipeline übergeben wurden, zentralen Zeitstempel nutzen
    IF @StartTime IS NULL SET @StartTime = @CurrentTime;
    IF @EndTime IS NULL   SET @EndTime   = @CurrentTime;

    -- 2. IngestionDate in der Ziel-Tabelle aktualisieren (Nur bei SUCCESS)
    IF @Status = 'SUCCESS' AND @UpdateIngestionColumn = 1
    BEGIN
        DECLARE @SqlUpdate NVARCHAR(MAX);
        
        SET @SqlUpdate = N'UPDATE ' + QUOTENAME(@TargetSchema) + N'.' + QUOTENAME(@TargetTable) + N'
                           SET [IngestionDateTime] = @IngestTime
                           WHERE [IngestionDateTime] IS NULL;';

        EXEC sp_executesql 
            @stmt = @SqlUpdate, 
            @params = N'@IngestTime DATETIME2(6)', 
            @IngestTime = @EndTime;
    END

    -- 3. Zeilenanzahl automatisch ermitteln (falls von Pipeline nicht übergeben)
    IF @RowsAffected IS NULL AND @Status = 'SUCCESS'
    BEGIN
        DECLARE @SqlCount NVARCHAR(MAX);
        DECLARE @CountResult BIGINT;
        
        SET @SqlCount = N'SELECT @CountOut = COUNT_BIG(1) FROM ' + QUOTENAME(@TargetSchema) + N'.' + QUOTENAME(@TargetTable) + N';';
        
        EXEC sp_executesql 
            @stmt = @SqlCount, 
            @params = N'@CountOut BIGINT OUTPUT', 
            @CountOut = @CountResult OUTPUT;
            
        SET @RowsAffected = @CountResult;
    END

    -- 4. Laufzeit berechnen
    DECLARE @DurationSeconds DECIMAL(10, 2) = DATEDIFF_BIG(MILLISECOND, @StartTime, @EndTime) / 1000.0;

    -- 5. Eintrag in die Log-Tabelle schreiben (inkl. CreatedEngineTime)
    INSERT INTO [meta].[TableLoadLog] (
        [ExecutionID],
        [TargetSchema],
        [TargetTable],
        [LoadType],
        [RowsAffected],
        [StartTime],
        [EndTime],
        [DurationSeconds],
        [Status],
        [ErrorMessage],
        [CreatedEngineTime]
    )
    VALUES (
        @ExecutionID,
        @TargetSchema,
        @TargetTable,
        @LoadType,
        ISNULL(@RowsAffected, 0),
        @StartTime,
        @EndTime,
        @DurationSeconds,
        @Status,
        @ErrorMessage,
        @CurrentTime  -- Exakter Einfüge-Zeitpunkt der Datenbank-Engine
    );
END;