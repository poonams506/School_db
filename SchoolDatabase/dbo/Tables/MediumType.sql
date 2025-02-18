CREATE TABLE [dbo].[MediumType]
(
	[MediumTypeId] INT NOT NULL,
	[MediumTypeName] NVARCHAR(100) NOT NULL,
	[MediumTypeKey] NVARCHAR(100) NULL,
	[IsDeleted] BIT DEFAULT((0)) NOT NULL,
	CONSTRAINT [PKMediumType] PRIMARY KEY CLUSTERED ([MediumTypeId] ASC)
)
