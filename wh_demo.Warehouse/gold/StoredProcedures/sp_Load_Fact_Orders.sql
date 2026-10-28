CREATE   PROCEDURE [gold].[sp_Load_Fact_Orders]
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Lokale Variable & Zeitstempel aus Utility-SP holen
    DECLARE @CurrentGoldTime DATETIME2(6);
    EXEC [util].[sp_GetIngestionTime] @IngestionTime = @CurrentGoldTime OUTPUT;

    -- 2. Idempotenz sicherstellen (Zieltabelle leeren)
    TRUNCATE TABLE [gold].[FactOrders];

    -- 3. Aggregierte Beladung auf Tagesebene mit striktem CAST
    INSERT INTO [gold].[FactOrders] (
        [CustomerID],
        [ProductID],
        [OrderDate],
        [OrderDateKey],
        [TotalOrderCount],
        [TotalQuantity],
        [SourceFileName],
        [IngestionDateTime],
        [LoadedToGoldDateTime]
    )
    SELECT 
        [CustomerID],
        [ProductID],
        
        CAST([OrderDate] AS DATE)                                   AS [OrderDate],
        CONVERT(INT, FORMAT(CAST([OrderDate] AS DATE), 'yyyyMMdd')) AS [OrderDateKey],
        
        -- Aggregationen (pro Kunde, Produkt und Datum)
        COUNT([OrderID])                                            AS [TotalOrderCount],
        SUM(CAST([Quantity] AS BIGINT))                             AS [TotalQuantity],
        
        -- Metadaten
        MAX([SourceFileName])                                       AS [SourceFileName],
        MAX([IngestionDateTime])                                    AS [IngestionDateTime],
        @CurrentGoldTime                                            AS [LoadedToGoldDateTime]

    FROM [bronze].[orders]
    
    GROUP BY 
        [CustomerID],
        [ProductID],
        CAST([OrderDate] AS DATE);
END;