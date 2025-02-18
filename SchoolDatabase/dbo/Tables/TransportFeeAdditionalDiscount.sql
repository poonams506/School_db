CREATE TABLE [dbo].[TransportFeeAdditionalDiscount]
(
	TransportFeeAdditionalDiscountId BIGINT IDENTITY(1, 1),
	AcademicYearId SMALLINT,
	ConsumerId BIGINT,
	TransportConsumerStoppageMappingId INT,
	RoleId INT,
    TransportFeePaymentId BIGINT,
	AdditionalDiscountedAmount MONEY,
	InstallmentPaybleFee MONEY,
	AdditionalDiscountedRemark NVARCHAR(200),
	CreatedBy INT, 
	CreatedDate DATETIME, 
	ModifiedBy INT, 
	ModifiedDate DATETIME, 
	IsDeleted BIT DEFAULT(0) NOT NULL,
	CONSTRAINT [PKTransportFeeAdditionalDiscount] PRIMARY KEY CLUSTERED (TransportFeeAdditionalDiscountId ASC),
	CONSTRAINT [FKTransportFeeAdditionalDiscountTransportFeePayment] FOREIGN KEY (TransportFeePaymentId) REFERENCES TransportFeePayment(TransportFeePaymentId),
	CONSTRAINT [FKTransportFeeAdditionalDiscountRole] FOREIGN KEY (RoleId) REFERENCES Role(RoleId),
	CONSTRAINT [FKTransportFeeAdditionalDiscountTransportConsumerStoppageMapping] FOREIGN KEY (TransportConsumerStoppageMappingId) REFERENCES TransportConsumerStoppageMapping(TransportConsumerStoppageMappingId)
)
