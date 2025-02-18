CREATE TYPE [dbo].[StudentKitFeeParticularType] AS TABLE
(
	FeeParticularId INT,
	ParticularName VARCHAR(100),
	Amount MONEY,
	SortBy SMALLINT
)
