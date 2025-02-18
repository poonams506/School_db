CREATE TABLE [dbo].[ClassTimeTableRowDetail]
(
	[ClassTimeTableRowDetailId] INT NOT NULL IDENTITY(1,1),
	[ClassTimeTableId] INT,
	[PeriodTypeId] INT,
	[StartingHour] INT,
	[StartingMinute] INT,
	[EndingHour] INT,
	[EndingMinute] INT,
	[SequenceId] INT,
	[CreatedBy] INT,
    [CreatedDate] DATETIME,
    [ModifiedBy] INT,
    [ModifiedDate] DATETIME,
	[IsDeleted] BIT DEFAULT((0)) NOT NULL,
	CONSTRAINT [PKClassTimeTableRowDetail] PRIMARY KEY CLUSTERED ([ClassTimeTableRowDetailId] ASC)
)
