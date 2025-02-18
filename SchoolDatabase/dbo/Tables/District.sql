CREATE TABLE [dbo].[District]
(
	[DistrictId] INT NOT NULL,
	[StateId] INT,
	[DistrictName] NVARCHAR(100) NOT NULL,
	[DistrictKey] NVARCHAR(100) NULL,
	[IsDeleted] BIT DEFAULT((0)) NOT NULL,
	CONSTRAINT [PKDistrict] PRIMARY KEY CLUSTERED ([DistrictId] ASC),
	CONSTRAINT [FKDistrictState] FOREIGN KEY (StateId) REFERENCES State(StateId),
)
