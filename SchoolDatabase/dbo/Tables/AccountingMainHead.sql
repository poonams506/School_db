CREATE TABLE [dbo].[AccountingMainHead]
(
	AccountingMainHeadId INT NOT NULL,
	Name NVARCHAR(250) NOT NULL,
	[IsDeleted] BIT DEFAULT((0)) NOT NULL,
	CONSTRAINT [PKAccountingMainHead] PRIMARY KEY CLUSTERED ([AccountingMainHeadId] ASC)
)
