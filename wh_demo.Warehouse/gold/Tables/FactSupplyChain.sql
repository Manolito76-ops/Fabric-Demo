CREATE TABLE [gold].[FactSupplyChain] (

	[ShipmentID] varchar(100) NOT NULL, 
	[ProductID] varchar(100) NULL, 
	[SupplierName] varchar(255) NULL, 
	[WarehouseName] varchar(255) NULL, 
	[OrderedQuantity] int NULL, 
	[LeadTimeDays] int NULL, 
	[DelayDays] int NULL, 
	[OrderStatus] varchar(100) NULL, 
	[OrderDate] date NULL, 
	[OrderDateKey] int NULL, 
	[DeliveryDate] date NULL, 
	[DeliveryDateKey] int NULL, 
	[SourceFileName] varchar(255) NULL, 
	[IngestionDateTime] datetime2(6) NULL, 
	[LoadedToGoldDateTime] datetime2(6) NOT NULL
);