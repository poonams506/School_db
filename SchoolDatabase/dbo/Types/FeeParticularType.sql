CREATE TYPE [dbo].[FeeParticularType] AS TABLE
(
	FeeParticularId INT,
	ParticularName VARCHAR(100),
	Amount MONEY,
	IsDiscountApplicable BIT,
	IsRTEApplicable BIT,
	SortBy SMALLINT
)
