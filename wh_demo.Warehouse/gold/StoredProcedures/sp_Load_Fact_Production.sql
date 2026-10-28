CREATE   PROCEDURE [gold].[sp_Load_Fact_Production]
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Lokale Variable deklarieren & Zeitstempel aus Utility-SP holen
    DECLARE @CurrentGoldTime DATETIME2(6);
    EXEC [util].[sp_GetIngestionTime] @IngestionTime = @CurrentGoldTime OUTPUT;

    -- 2. Idempotenz sicherstellen (Zieltabelle leeren)
    TRUNCATE TABLE [gold].[FactProduction];

    -- 3. Aggregierte Beladung auf Tagesebene mit striktem CAST
    INSERT INTO [gold].[FactProduction] (
        [ProductID],
        [Plant],
        [Machine],
        [ProductionDate],
        [ProductionDateKey],
        [TotalProductionRuns],
        [TotalPlannedQuantity],
        [TotalProducedQuantity],
        [TotalDefectiveQuantity],
        [TotalDurationHours],
        [SourceFileName],
        [IngestionDateTime],
        [LoadedToGoldDateTime]
    )
    SELECT 
        [ProductID],
        [Plant],
        [Machine],
        
        CAST([ProductionDate] AS DATE)                                   AS [ProductionDate],
        -- Performanter Integer DateKey (YYYYMMDD) ohne langsames FORMAT()
        CAST(CONVERT(VARCHAR(8), CAST([ProductionDate] AS DATE), 112) AS INT) AS [ProductionDateKey],
        
        -- Kennzahlen (Aggregiert auf Tagesebene pro Product, Plant, Machine, Date)
        COUNT([ProductionID])                                           AS [TotalProductionRuns],
        SUM(CAST([PlannedQuantity] AS BIGINT))                          AS [TotalPlannedQuantity],
        SUM(CAST([ProducedQuantity] AS BIGINT))                         AS [TotalProducedQuantity],
        SUM(CAST([DefectiveQuantity] AS BIGINT))                        AS [TotalDefectiveQuantity],
        SUM(CAST([DurationHours] AS DECIMAL(10,2)))                     AS [TotalDurationHours],
        
        -- Metadaten
        MAX([SourceFileName])                                           AS [SourceFileName],
        MAX([IngestionDateTime])                                        AS [IngestionDateTime],
        @CurrentGoldTime                                                AS [LoadedToGoldDateTime]

    FROM [bronze].[production]
    
    GROUP BY 
        [ProductID],
        [Plant],
        [Machine],
        CAST([ProductionDate] AS DATE),
        CAST(CONVERT(VARCHAR(8), CAST([ProductionDate] AS DATE), 112) AS INT);
END;