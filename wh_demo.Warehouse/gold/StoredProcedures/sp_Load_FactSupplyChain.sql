CREATE PROCEDURE [gold].[sp_Load_FactSupplyChain]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ExecutionDateTime DATETIME2(6) = CAST(SYSUTCDATETIME() AT TIME ZONE 'UTC' AT TIME ZONE 'Central European Standard Time' AS DATETIME2(6));

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
        TRIM(bsc.[ShipmentID]),
        TRIM(bsc.[ProductID]),
        TRIM(bsc.[Supplier]),
        TRIM(bsc.[Warehouse]),
        TRY_CAST(bsc.[OrderedQuantity] AS INT),
        TRY_CAST(bsc.[LeadTimeDays] AS INT),
        TRY_CAST(bsc.[DelayDays] AS INT),
        TRIM(bsc.[OrderStatus]),
        TRY_CAST(bsc.[OrderDate] AS DATE),
        TRY_CAST(CONVERT(VARCHAR(8), TRY_CAST(bsc.[OrderDate] AS DATE), 112) AS INT),
        TRY_CAST(bsc.[DeliveryDate] AS DATE),
        TRY_CAST(CONVERT(VARCHAR(8), TRY_CAST(bsc.[DeliveryDate] AS DATE), 112) AS INT),
        bsc.[SourceFileName],
        TRY_CAST(bsc.[IngestionDateTime] AS DATETIME2(6)),
        @ExecutionDateTime
    FROM [bronze].[supply_chain] bsc
    LEFT JOIN [gold].[FactSupplyChain] fsc ON TRIM(bsc.[ShipmentID]) = fsc.[ShipmentID]
    WHERE bsc.[ShipmentID] IS NOT NULL 
      AND TRIM(bsc.[ShipmentID]) <> ''
      AND fsc.[ShipmentID] IS NULL; -- Upsert: Nur neue ShipmentIDs einfügen
END;