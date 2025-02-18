CREATE TABLE [dbo].[Grade]
(
	[GradeId] SMALLINT NOT NULL IDENTITY(1,1),
	[GradeName] NVARCHAR(50) NOT NULL,
	[CreatedBy] INT,
    [CreatedDate] DATETIME,
    [ModifiedBy] INT,
    [ModifiedDate] DATETIME,
	[IsDeleted] BIT DEFAULT((0)) NOT NULL,
	CONSTRAINT [PKGrade] PRIMARY KEY CLUSTERED ([GradeId] ASC)
)
