CREATE  PROCEDURE [bronze].[sp_Load_bom]
AS
BEGIN
    SET NOCOUNT ON;

    -- Einfügen aller Daten aus der Staging-Tabelle in die Bronze-Tabelle
    INSERT INTO [bronze].[bom] (
       [ProductID]
      ,[PartID]
      ,[QuantityPerProduct]
      ,[Unit]
      ,[IngestionDateTime]
      ,[SourceFileName]
    )
    Select [ProductID]
      ,[PartID]
      ,[QuantityPerProduct]
      ,[Unit]
      ,[IngestionDateTime]
      ,[SourceFileName]
    FROM [stg].[bom]

    
END;