CREATE  PROCEDURE [bronze].[sp_Load_production]
AS
BEGIN
    SET NOCOUNT ON;

    -- Einfügen aller Daten aus der Staging-Tabelle in die Bronze-Tabelle
    INSERT INTO bronze.[production] (
        [ProductionID],
	   [ProductID],
	   [Plant],
	   [Machine],
	   [PlannedQuantity],
	   [ProducedQuantity],
	   [DefectiveQuantity],
	   [DurationHours],
	   [ProductionDate],
	   [IngestionDateTime],
	   [SourceFileName]
    )
    SELECT
       [ProductionID],
	   [ProductID],
	   [Plant],
	   [Machine],
	   [PlannedQuantity],
	   [ProducedQuantity],
	   [DefectiveQuantity],
	   [DurationHours],
	   [ProductionDate],
	   [IngestionDateTime],
	   [SourceFileName]
    FROM stg.[production];
    
END;