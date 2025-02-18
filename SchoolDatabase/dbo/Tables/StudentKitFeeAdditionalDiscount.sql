CREATE TABLE [dbo].[StudentKitFeeAdditionalDiscount]
(
	StudentKitFeeAdditionalDiscountId BIGINT IDENTITY(1, 1),
	AcademicYearId SMALLINT,
	StudentId BIGINT,
    StudentKitFeePaymentId BIGINT,
	AdditionalDiscountedAmount MONEY,
	InstallmentPaybleFee MONEY,
	AdditionalDiscountedRemark NVARCHAR(200),
	CreatedBy INT, 
	CreatedDate DATETIME, 
	ModifiedBy INT, 
	ModifiedDate DATETIME, 
	IsDeleted BIT DEFAULT(0) NOT NULL,
	CONSTRAINT [PKStudentKitFeeAdditionalDiscount] PRIMARY KEY CLUSTERED (StudentKitFeeAdditionalDiscountId ASC),
	CONSTRAINT [FKStudentKitFeeAdditionalDiscountStudentKitFeePayment] FOREIGN KEY (StudentKitFeePaymentId) REFERENCES StudentKitFeePayment(StudentKitFeePaymentId),
	CONSTRAINT [FKStudentKitFeeAdditionalDiscountStudent] FOREIGN KEY (StudentId) REFERENCES Student(StudentId)
)
