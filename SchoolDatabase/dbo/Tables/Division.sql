CREATE TABLE [dbo].[Division]
(
	[DivisionId] SMALLINT NOT NULL IDENTITY(1,1),
	[DivisionName] NVARCHAR(50) NOT NULL,
	[CreatedBy] INT,
    [CreatedDate] DATETIME,
    [ModifiedBy] INT,
    [ModifiedDate] DATETIME,
	[IsDeleted] BIT DEFAULT((0)) NOT NULL,
	CONSTRAINT [PKDivision] PRIMARY KEY CLUSTERED ([DivisionId] ASC)
)
