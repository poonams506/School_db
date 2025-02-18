CREATE TABLE [dbo].[FeeAdditionalDiscount]
(
	FeeAdditionalDiscountId BIGINT IDENTITY(1, 1),
	AcademicYearId SMALLINT,
	StudentId BIGINT,
    FeePaymentId BIGINT,
	AdditionalDiscountedAmount MONEY,
	InstallmentPaybleFee MONEY,
	AdditionalDiscountedRemark NVARCHAR(200),
	CreatedBy INT, 
	CreatedDate DATETIME, 
	ModifiedBy INT, 
	ModifiedDate DATETIME, 
	IsDeleted BIT DEFAULT(0) NOT NULL,
	CONSTRAINT [PKFeeAdditionalDiscount] PRIMARY KEY CLUSTERED (FeeAdditionalDiscountId ASC),
	CONSTRAINT [FKFeeAdditionalDiscountFeePayment] FOREIGN KEY (FeePaymentId) REFERENCES FeePayment(FeePaymentId),
	CONSTRAINT [FKFeeAdditionalDiscountStudent] FOREIGN KEY (StudentId) REFERENCES Student(StudentId)
)
