CREATE TABLE [dbo].[State]
(
	[StateId] INT NOT NULL,
	[CountryId] INT,
	[StateName] NVARCHAR(100) NOT NULL,
	[StateKey] NVARCHAR(100) NULL,
	[IsDeleted] BIT DEFAULT((0)) NOT NULL,
	CONSTRAINT [PKState] PRIMARY KEY CLUSTERED ([StateId] ASC),
	CONSTRAINT [FKStateCountry] FOREIGN KEY (CountryId) REFERENCES Country(CountryId),
)
