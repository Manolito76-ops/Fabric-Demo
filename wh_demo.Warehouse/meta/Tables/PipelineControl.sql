CREATE TABLE [meta].[PipelineControl] (

	[ID] int NOT NULL, 
	[SourceSchema] varchar(50) NOT NULL, 
	[SourceTable] varchar(100) NOT NULL, 
	[TargetSchema] varchar(50) NOT NULL, 
	[TargetTable] varchar(100) NOT NULL, 
	[LoadType] varchar(20) NOT NULL, 
	[UpdateIngestionColumn] bit NOT NULL, 
	[IsActive] bit NOT NULL
);


GO
ALTER TABLE [meta].[PipelineControl] ADD CONSTRAINT PK_PipelineControl primary key NONCLUSTERED ([ID]);