CREATE TABLE [bronze].[supply_chain] (

	[ShipmentID] varchar(8000) NULL, 
	[ProductID] varchar(8000) NULL, 
	[Supplier] varchar(8000) NULL, 
	[Warehouse] varchar(8000) NULL, 
	[OrderedQuantity] varchar(8000) NULL, 
	[LeadTimeDays] varchar(8000) NULL, 
	[DelayDays] varchar(8000) NULL, 
	[OrderStatus] varchar(8000) NULL, 
	[OrderDate] varchar(8000) NULL, 
	[DeliveryDate] varchar(8000) NULL, 
	[IngestionDateTime] varchar(8000) NULL, 
	[SourceFileName] varchar(250) NULL
);