CREATE TABLE [dbo].[AdhocParticularMaster]
(
	AdhocParticularMasterId  SMALLINT IDENTITY(1, 1) NOT NULL,
	Particular NVARCHAR(100) NOT NULL,
	CreatedBy INT,
    CreatedDate DATETIME,
    ModifiedBy INT,
    ModifiedDate DATETIME,
	IsDeleted BIT DEFAULT((0)) NOT NULL,
	CONSTRAINT [PKAdhocParticularMaster] PRIMARY KEY CLUSTERED ([AdhocParticularMasterId] ASC)
)


