CREATE TYPE [dbo].[TransportFeePaymentAppliedMonthMappingType] AS TABLE
(
	MonthMasterId INT,
	DiscountedPercent NUMERIC(5,4),
	DiscountedAmount MONEY
)
