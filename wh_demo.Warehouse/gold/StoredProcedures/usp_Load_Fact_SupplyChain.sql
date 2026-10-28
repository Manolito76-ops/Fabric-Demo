CREATE   PROCEDURE [gold].[usp_Load_Fact_SupplyChain]
AS
BEGIN
    SET NOCOUNT ON;

    -- Idempotenz: Gold vor dem Neuaufbau leeren
    TRUNCATE TABLE [gold].[FactSupplyChain];

    INSERT INTO [gold].[FactSupplyChain] (
        [ShipmentID],
        [ProductID],
        [SupplierName],
        [WarehouseName],
        [OrderedQuantity],
        [LeadTimeDays],
        [DelayDays],
        [OrderStatus],
        [OrderDate],
        [OrderDateKey],
        [DeliveryDate],
        [DeliveryDateKey],
        [SourceFileName],
        [IngestionDateTime],
        [LoadedToGoldDateTime]
    )
    SELECT 
        [ShipmentID],
        [ProductID],
        [Supplier]                              AS [SupplierName],
        [Warehouse]                             AS [WarehouseName],
        [OrderedQuantity],
        [LeadTimeDays],
        [DelayDays],
        [OrderStatus],
        CAST([OrderDate] AS DATE)               AS [OrderDate],
        -- Erzeugt ein sauberes DateKey Format (z.B. 20260922)
        CONVERT(INT, FORMAT(CAST([OrderDate] AS DATE), 'yyyyMMdd')) AS [OrderDateKey],
        
        CAST([DeliveryDate] AS DATE)            AS [DeliveryDate],
        CONVERT(INT, FORMAT(CAST([DeliveryDate] AS DATE), 'yyyyMMdd')) AS [DeliveryDateKey],
        
        [SourceFileName],
        [IngestionDateTime],
        -- Lokaler deutscher Zeitstempel für den Gold-Upload
        CAST(SYSDATETIMEOFFSET() AT TIME ZONE 'W. Europe Standard Time' AS DATETIME2) AS [LoadedToGoldDateTime]

    FROM [bronze].[supply_chain];
END;