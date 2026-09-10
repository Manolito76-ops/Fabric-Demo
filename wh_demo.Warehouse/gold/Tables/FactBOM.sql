CREATE TABLE [gold].[FactBOM] (

	[ProductID] varchar(100) NOT NULL, 
	[PartID] varchar(100) NOT NULL, 
	[QuantityPerProduct] decimal(18,4) NULL, 
	[Unit] varchar(50) NULL, 
	[SourceFileName] varchar(255) NULL, 
	[IngestionDateTime] datetime2(6) NULL, 
	[LoadedToGoldDateTime] datetime2(6) NOT NULL
);