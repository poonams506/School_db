CREATE TABLE [dbo].[Country]
(
	[CountryId] INT NOT NULL,
	[CountryName] NVARCHAR(100) NOT NULL,
	[CountryKey] NVARCHAR(100) NULL,
	[IsDeleted] BIT DEFAULT((0)) NOT NULL,
	CONSTRAINT [PKCountry] PRIMARY KEY CLUSTERED ([CountryId] ASC)
)
