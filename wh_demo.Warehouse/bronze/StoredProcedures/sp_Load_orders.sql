CREATE   PROCEDURE [bronze].[sp_Load_orders]
AS
BEGIN
    SET NOCOUNT ON;

    -- Einfügen aller Daten aus der Staging-Tabelle in die Bronze-Tabelle
    INSERT INTO bronze.[orders] (
        [OrderID],
        [CustomerID],
        [ProductID],
        [Quantity],
        [OrderDate],
        [IngestionDateTime],
        [SourceFileName]
        
        --SourceFileName
    )
    SELECT 
        [OrderID],
        [CustomerID],
        [ProductID],
        [Quantity],
        [OrderDate],
        [IngestionDateTime],
        [SourceFileName]
        
        -- SourceFileName
    FROM stg.[orders];

END;