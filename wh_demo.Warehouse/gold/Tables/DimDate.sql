CREATE TABLE [gold].[DimDate] (

	[DateKey] int NOT NULL, 
	[FullDate] date NOT NULL, 
	[Year] int NOT NULL, 
	[Quarter] int NOT NULL, 
	[Month] int NOT NULL, 
	[MonthName] varchar(20) NOT NULL, 
	[Day] int NOT NULL, 
	[DayOfWeek] int NOT NULL, 
	[DayName] varchar(20) NOT NULL, 
	[IsWeekend] bit NOT NULL
);