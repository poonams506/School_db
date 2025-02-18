CREATE TABLE [dbo].[Taluka]
(
	[TalukaId] INT NOT NULL,
	[DistrictId] INT,
	[TalukaName] NVARCHAR(100) NOT NULL,
	[TalukaKey] NVARCHAR(100) NULL,
	[IsDeleted] BIT DEFAULT((0)) NOT NULL,
	CONSTRAINT [PKTaluka] PRIMARY KEY CLUSTERED ([TalukaId] ASC),
	CONSTRAINT [FKTalukaDistrict] FOREIGN KEY (DistrictId) REFERENCES District(DistrictId),
)
