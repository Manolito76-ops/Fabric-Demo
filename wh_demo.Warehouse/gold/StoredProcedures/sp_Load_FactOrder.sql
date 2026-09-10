CREATE PROCEDURE [gold].[sp_Load_FactOrder]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ExecutionDateTime DATETIME2(6) = CAST(SYSUTCDATETIME() AT TIME ZONE 'UTC' AT TIME ZONE 'Central European Standard Time' AS DATETIME2(6));

    INSERT INTO [gold].[FactOrder] (
        [OrderID],
        [CustomerID],
        [ProductID],
        [OrderDate],
        [OrderDateKey],
        [Quantity],
        [SourceFileName],
        [IngestionDateTime],
        [LoadedToGoldDateTime]
    )
    SELECT 
        TRIM(bo.[OrderID]),
        TRIM(bo.[CustomerID]),
        TRIM(bo.[ProductID]),
        TRY_CAST(bo.[OrderDate] AS DATE),
        TRY_CAST(CONVERT(VARCHAR(8), TRY_CAST(bo.[OrderDate] AS DATE), 112) AS INT),
        TRY_CAST(bo.[Quantity] AS INT),
        bo.[SourceFileName],
        TRY_CAST(bo.[IngestionDateTime] AS DATETIME2(6)),
        @ExecutionDateTime
    FROM [bronze].[orders] bo
    LEFT JOIN [gold].[FactOrder] fo ON TRIM(bo.[OrderID]) = fo.[OrderID]
    WHERE bo.[OrderID] IS NOT NULL 
      AND TRIM(bo.[OrderID]) <> ''
      AND fo.[OrderID] IS NULL; -- Upsert: Nur neue OrderIDs einfügen
END;