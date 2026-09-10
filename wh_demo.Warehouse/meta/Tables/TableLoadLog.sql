CREATE TABLE [meta].[TableLoadLog] (

	[ExecutionID] varchar(36) NOT NULL, 
	[TargetSchema] varchar(50) NOT NULL, 
	[TargetTable] varchar(100) NOT NULL, 
	[LoadType] varchar(20) NOT NULL, 
	[RowsAffected] bigint NOT NULL, 
	[StartTime] datetime2(6) NOT NULL, 
	[EndTime] datetime2(6) NOT NULL, 
	[DurationSeconds] decimal(10,2) NULL, 
	[Status] varchar(20) NOT NULL, 
	[ErrorMessage] varchar(max) NULL
);