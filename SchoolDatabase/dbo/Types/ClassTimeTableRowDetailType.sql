CREATE TYPE [dbo].[ClassTimeTableRowDetailType] AS TABLE
(
	[ClassTimeTableId] INT,
	[PeriodTypeId] INT,
	[StartingHour] INT,
	[StartingMinute] INT,
	[EndingHour] INT,
	[EndingMinute] INT,
	[SequenceId] INT
)
