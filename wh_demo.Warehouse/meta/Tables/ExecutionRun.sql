CREATE TABLE [meta].[ExecutionRun] (

	[ExecutionID] varchar(36) NOT NULL, 
	[PipelineName] varchar(100) NOT NULL, 
	[Status] varchar(20) NOT NULL, 
	[StartTime] datetime2(6) NOT NULL, 
	[EndTime] datetime2(6) NULL, 
	[ErrorMessage] varchar(max) NULL
);