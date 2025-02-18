CREATE TABLE [dbo].[ClassTimeTable]
(
	[ClassTimeTableId] INT NOT NULL IDENTITY(1,1),
	[ClassTimeTableName] NVARCHAR(150) NOT NULL,
	[GradeId] INT,
	[DivisionId] INT,
	[AcademicYearId] INT,
	[CreatedBy] INT,
    [CreatedDate] DATETIME,
    [ModifiedBy] INT,
    [ModifiedDate] DATETIME,
	[isActive] BIT DEFAULT(0) NOT NULL,
	[IsDeleted] BIT DEFAULT((0)) NOT NULL,
	CONSTRAINT [PKClassTimeTable] PRIMARY KEY CLUSTERED ([ClassTimeTableId] ASC)
)
