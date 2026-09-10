CREATE TABLE [gold].[FactProduction] (

	[ProductionID] varchar(100) NOT NULL, 
	[ProductID] varchar(100) NULL, 
	[Plant] varchar(100) NULL, 
	[Machine] varchar(100) NULL, 
	[PlannedQuantity] int NULL, 
	[ProducedQuantity] int NULL, 
	[DefectiveQuantity] int NULL, 
	[DurationHours] decimal(10,2) NULL, 
	[ProductionDate] date NULL, 
	[ProductionDateKey] int NULL, 
	[SourceFileName] varchar(255) NULL, 
	[IngestionDateTime] datetime2(6) NULL, 
	[LoadedToGoldDateTime] datetime2(6) NOT NULL
);