CREATE TABLE [gold].[FactProduction] (

	[ProductID] varchar(100) NULL, 
	[Plant] varchar(100) NULL, 
	[Machine] varchar(100) NULL, 
	[ProductionDate] date NULL, 
	[ProductionDateKey] int NULL, 
	[TotalProductionRuns] int NULL, 
	[TotalPlannedQuantity] bigint NULL, 
	[TotalProducedQuantity] bigint NULL, 
	[TotalDefectiveQuantity] bigint NULL, 
	[TotalDurationHours] decimal(10,2) NULL, 
	[SourceFileName] varchar(255) NULL, 
	[IngestionDateTime] datetime2(6) NULL, 
	[LoadedToGoldDateTime] datetime2(6) NOT NULL
);