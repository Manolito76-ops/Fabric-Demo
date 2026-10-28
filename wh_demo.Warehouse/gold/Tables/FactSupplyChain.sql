CREATE TABLE [gold].[FactSupplyChain] (

	[ProductID] varchar(50) NOT NULL, 
	[SupplierName] varchar(100) NULL, 
	[WarehouseName] varchar(100) NULL, 
	[OrderStatus] varchar(50) NULL, 
	[OrderDate] date NULL, 
	[OrderDateKey] int NULL, 
	[DeliveryDate] date NULL, 
	[DeliveryDateKey] int NULL, 
	[TotalShipmentCount] int NULL, 
	[TotalOrderedQuantity] bigint NULL, 
	[AvgLeadTimeDays] decimal(10,2) NULL, 
	[MaxDelayDays] int NULL, 
	[SourceFileName] varchar(255) NULL, 
	[IngestionDateTime] datetime2(6) NULL, 
	[LoadedToGoldDateTime] datetime2(6) NULL
);