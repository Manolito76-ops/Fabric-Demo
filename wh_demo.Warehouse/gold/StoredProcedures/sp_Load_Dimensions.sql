CREATE PROCEDURE [gold].[sp_Load_Dimensions]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ExecutionDateTime DATETIME2(7) = CAST(SYSUTCDATETIME() AT TIME ZONE 'UTC' AT TIME ZONE 'Central European Standard Time' AS DATETIME2(7));

    ----------------------------------------------------------------------
    -- 1. DimCustomer (Upsert)
    ----------------------------------------------------------------------
    INSERT INTO [gold].[DimCustomer] ([CustomerID], [CustomerName], [CreatedInGoldDateTime])
    SELECT DISTINCT 
        TRIM(bo.[CustomerID]), 
        TRIM(bo.[CustomerID]), 
        @ExecutionDateTime
    FROM [bronze].[orders] bo
    LEFT JOIN [gold].[DimCustomer] dc ON TRIM(bo.[CustomerID]) = dc.[CustomerID]
    WHERE bo.[CustomerID] IS NOT NULL AND TRIM(bo.[CustomerID]) <> '' AND dc.[CustomerID] IS NULL;

    ----------------------------------------------------------------------
    -- 2. DimProduct (Upsert inklusive ALLER PartIDs aus der BOM!)
    ----------------------------------------------------------------------
    INSERT INTO [gold].[DimProduct] ([ProductID], [CreatedInGoldDateTime])
    SELECT DISTINCT src.[ProductID], @ExecutionDateTime
    FROM (
        SELECT TRIM([ProductID]) AS ProductID FROM [bronze].[orders] WHERE [ProductID] IS NOT NULL AND TRIM([ProductID]) <> ''
        UNION
        SELECT TRIM([ProductID]) AS ProductID FROM [bronze].[production] WHERE [ProductID] IS NOT NULL AND TRIM([ProductID]) <> ''
        UNION
        SELECT TRIM([ProductID]) AS ProductID FROM [bronze].[supply_chain] WHERE [ProductID] IS NOT NULL AND TRIM([ProductID]) <> ''
        UNION
        SELECT TRIM([ProductID]) AS ProductID FROM [bronze].[bom] WHERE [ProductID] IS NOT NULL AND TRIM([ProductID]) <> ''
        UNION
        -- WICHTIG: Auch die Rohmaterialien/Einzelteile erfassen!
        SELECT TRIM([PartID]) AS ProductID FROM [bronze].[bom] WHERE [PartID] IS NOT NULL AND TRIM([PartID]) <> ''
    ) src
    LEFT JOIN [gold].[DimProduct] dp ON src.[ProductID] = dp.[ProductID]
    WHERE dp.[ProductID] IS NULL;

    ----------------------------------------------------------------------
    -- 3. DimSupplier (NEU: Für Supply Chain Analyse)
    ----------------------------------------------------------------------
    INSERT INTO [gold].[DimSupplier] ([SupplierName], [CreatedInGoldDateTime])
    SELECT DISTINCT TRIM(bsc.[Supplier]), @ExecutionDateTime
    FROM [bronze].[supply_chain] bsc
    LEFT JOIN [gold].[DimSupplier] ds ON TRIM(bsc.[Supplier]) = ds.[SupplierName]
    WHERE bsc.[Supplier] IS NOT NULL AND TRIM(bsc.[Supplier]) <> '' AND ds.[SupplierName] IS NULL;

END;