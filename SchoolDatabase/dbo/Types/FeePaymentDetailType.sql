CREATE TYPE [dbo].[FeePaymentDetailType] AS TABLE
(
	FeeParticularId BIGINT,
	OtherFeeReason NVARCHAR(500),
	FeeAfterDiscount MONEY,
	PaidAmount MONEY,
	AdditionalDiscInPercentage NUMERIC(5,4),
	AdditionalDiscAmount MONEY
)
