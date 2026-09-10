CREATE PROCEDURE [gold].[sp_Load_FactBOM]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ExecutionDateTime DATETIME2(6) = CAST(SYSUTCDATETIME() AT TIME ZONE 'UTC' AT TIME ZONE 'Central European Standard Time' AS DATETIME2(6));

    INSERT INTO [gold].[FactBOM] (
        [ProductID],
        [PartID],
        [QuantityPerProduct],
        [Unit],
        [SourceFileName],
        [IngestionDateTime],
        [LoadedToGoldDateTime]
    )
    SELECT 
        TRIM(bb.[ProductID]),
        TRIM(bb.[PartID]),
        TRY_CAST(REPLACE(bb.[QuantityPerProduct], ',', '.') AS DECIMAL(18, 4)),
        TRIM(bb.[Unit]),
        bb.[SourceFileName],
        TRY_CAST(bb.[IngestionDateTime] AS DATETIME2(6)),
        @ExecutionDateTime
    FROM [bronze].[bom] bb
    LEFT JOIN [gold].[FactBOM] fb 
        ON TRIM(bb.[ProductID]) = fb.[ProductID] 
       AND TRIM(bb.[PartID]) = fb.[PartID]
    WHERE bb.[ProductID] IS NOT NULL 
      AND TRIM(bb.[ProductID]) <> ''
      AND bb.[PartID] IS NOT NULL 
      AND TRIM(bb.[PartID]) <> ''
      AND fb.[ProductID] IS NULL; -- Upsert: Nur neue Produkt-Teil-Beziehungen einfügen
END;