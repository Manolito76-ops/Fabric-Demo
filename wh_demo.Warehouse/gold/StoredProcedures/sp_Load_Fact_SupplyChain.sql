CREATE   PROCEDURE [gold].[sp_Load_Fact_SupplyChain]
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Lokale Variable & Zeitstempel holen
    DECLARE @CurrentGoldTime DATETIME2(6);
    EXEC [util].[sp_GetIngestionTime] @IngestionTime = @CurrentGoldTime OUTPUT;

    -- 2. Idempotenz: Zieltabelle leeren
    TRUNCATE TABLE [gold].[FactSupplyChain];

    -- 3. Aggregierte Beladung mit expliziter Typkonvertierung
    INSERT INTO [gold].[FactSupplyChain] (
        [ProductID],
        [SupplierName],
        [WarehouseName],
        [OrderStatus],
        [OrderDate],
        [OrderDateKey],
        [DeliveryDate],
        [DeliveryDateKey],
        [TotalShipmentCount],
        [TotalOrderedQuantity],
        [AvgLeadTimeDays],
        [MaxDelayDays],
        [SourceFileName],
        [IngestionDateTime],
        [LoadedToGoldDateTime]
    )
    SELECT 
        [ProductID],
        [Supplier]                                                  AS [SupplierName],
        [Warehouse]                                                 AS [WarehouseName],
        [OrderStatus],
        
        CAST([OrderDate] AS DATE)                                   AS [OrderDate],
        CONVERT(INT, FORMAT(CAST([OrderDate] AS DATE), 'yyyyMMdd')) AS [OrderDateKey],
        
        CAST([DeliveryDate] AS DATE)                                AS [DeliveryDate],
        CONVERT(INT, FORMAT(CAST([DeliveryDate] AS DATE), 'yyyyMMdd')) AS [DeliveryDateKey],
        
        -- Kennzahlen (sicheres Casting von VARCHAR zu NUMERIC)
        COUNT([ShipmentID])                                         AS [TotalShipmentCount],
        SUM(TRY_CAST([OrderedQuantity] AS BIGINT))                  AS [TotalOrderedQuantity],
        AVG(TRY_CAST([LeadTimeDays] AS DECIMAL(10,2)))              AS [AvgLeadTimeDays],
        MAX(TRY_CAST([DelayDays] AS INT))                           AS [MaxDelayDays],
        
        -- Meta-Felder
        MAX([SourceFileName])                                       AS [SourceFileName],
        MAX([IngestionDateTime])                                    AS [IngestionDateTime],
        @CurrentGoldTime                                            AS [LoadedToGoldDateTime]

    FROM [bronze].[supply_chain]
    
    GROUP BY 
        [ProductID],
        [Supplier],
        [Warehouse],
        [OrderStatus],
        CAST([OrderDate] AS DATE),
        CAST([DeliveryDate] AS DATE);
END;