CREATE   PROCEDURE [bronze].[sp_Load_supply_chain]
AS
BEGIN
    SET NOCOUNT ON;

    -- Einfügen aller Daten aus der Staging-Tabelle in die Bronze-Tabelle
    INSERT INTO bronze.[supply_chain] (
        [ShipmentID],
	   [ProductID],
	   [Supplier],
	   [Warehouse],
	   [OrderedQuantity],
	   [LeadTimeDays],
	   [DelayDays],
	   [OrderStatus],
	   [OrderDate],
	   [DeliveryDate],
	   [IngestionDateTime],
	   [SourceFileName]
    )
    Select [ShipmentID],
	   [ProductID],
	   [Supplier],
	   [Warehouse],
	   [OrderedQuantity],
	   [LeadTimeDays],
	   [DelayDays],
	   [OrderStatus],
	   [OrderDate],
	   [DeliveryDate],
	   [IngestionDateTime],
	   [SourceFileName]
from stg.[supply_chain]
    
END;