CREATE TYPE [dbo].[FeePaymentAppliedWavierMappingType] AS TABLE
(
	FeeParticularWavierMappingId BIGINT,
	DiscountedPercent NUMERIC(5,4),
	DiscountedAmount MONEY
)
