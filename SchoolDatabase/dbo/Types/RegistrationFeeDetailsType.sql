CREATE TYPE [dbo].[RegistrationFeeDetailsType] AS TABLE
(
	FeeParticularId BIGINT,
	InvoiceNumber VARCHAR(100),
	PaidAmount MONEY,
	PaymentTypeId SMALLINT
)
