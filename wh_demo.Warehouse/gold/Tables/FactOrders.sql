CREATE TABLE [gold].[FactOrders] (

	[CustomerID] varchar(100) NULL, 
	[ProductID] varchar(100) NULL, 
	[OrderDate] date NULL, 
	[OrderDateKey] int NULL, 
	[TotalOrderCount] int NULL, 
	[TotalQuantity] bigint NULL, 
	[SourceFileName] varchar(255) NULL, 
	[IngestionDateTime] datetime2(6) NULL, 
	[LoadedToGoldDateTime] datetime2(6) NOT NULL
);