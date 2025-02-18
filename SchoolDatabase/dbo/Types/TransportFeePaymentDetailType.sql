CREATE TYPE [dbo].[TransportFeePaymentDetailType] AS TABLE
(
	OtherFeeReason NVARCHAR(500),
	FeeAfterDiscount MONEY,
	PaidAmount MONEY,
	AdditionalDiscInPercentage NUMERIC(5,4),
	AdditionalDiscAmount MONEY
)
