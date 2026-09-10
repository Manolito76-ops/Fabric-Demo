CREATE PROCEDURE [gold].[sp_Load_FactProduction]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ExecutionDateTime DATETIME2(6) = CAST(SYSUTCDATETIME() AT TIME ZONE 'UTC' AT TIME ZONE 'Central European Standard Time' AS DATETIME2(6));

    INSERT INTO [gold].[FactProduction] (
        [ProductionID],
        [ProductID],
        [Plant],
        [Machine],
        [PlannedQuantity],
        [ProducedQuantity],
        [DefectiveQuantity],
        [DurationHours],
        [ProductionDate],
        [ProductionDateKey],
        [SourceFileName],
        [IngestionDateTime],
        [LoadedToGoldDateTime]
    )
    SELECT 
        TRIM(bp.[ProductionID]),
        TRIM(bp.[ProductID]),
        TRIM(bp.[Plant]),
        TRIM(bp.[Machine]),
        TRY_CAST(bp.[PlannedQuantity] AS INT),
        TRY_CAST(bp.[ProducedQuantity] AS INT),
        TRY_CAST(bp.[DefectiveQuantity] AS INT),
        TRY_CAST(REPLACE(bp.[DurationHours], ',', '.') AS DECIMAL(10, 2)),
        TRY_CAST(bp.[ProductionDate] AS DATE),
        TRY_CAST(CONVERT(VARCHAR(8), TRY_CAST(bp.[ProductionDate] AS DATE), 112) AS INT),
        bp.[SourceFileName],
        TRY_CAST(bp.[IngestionDateTime] AS DATETIME2(6)),
        @ExecutionDateTime
    FROM [bronze].[production] bp
    LEFT JOIN [gold].[FactProduction] fp ON TRIM(bp.[ProductionID]) = fp.[ProductionID]
    WHERE bp.[ProductionID] IS NOT NULL 
      AND TRIM(bp.[ProductionID]) <> ''
      AND fp.[ProductionID] IS NULL; -- Upsert: Nur neue ProductionIDs einfügen
END;