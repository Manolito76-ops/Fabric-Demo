CREATE TABLE [gold].[FactOrder] (

	[OrderID] varchar(100) NOT NULL, 
	[CustomerID] varchar(100) NULL, 
	[ProductID] varchar(100) NULL, 
	[OrderDate] date NULL, 
	[OrderDateKey] int NULL, 
	[Quantity] int NULL, 
	[SourceFileName] varchar(255) NULL, 
	[IngestionDateTime] datetime2(6) NULL, 
	[LoadedToGoldDateTime] datetime2(6) NOT NULL
);