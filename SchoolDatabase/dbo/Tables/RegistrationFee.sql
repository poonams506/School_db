CREATE TABLE [dbo].[RegistrationFee]
(
	RegistrationFeeId BIGINT IDENTITY(1,1),
	StudentEnquiryId INT,
	AcademicYearId SMALLINT,
	RegistrationInvoiceNumber VARCHAR(100),
	OnlineTransactionId VARCHAR(300),
	OnlineTransactionDateTime DATETIME,
	OnlinePaymentRequest varchar(1000),
	OnlinePaymentResponse varchar(1000),
	PaidToBank nvarchar(100), 
	PaidAmount money,
	PaymentTypeId smallint,
	Remark nvarchar(200),
	CreatedBy int,
	CreatedDate datetime,
	ModifiedBy int,
	ModifiedDate datetime,
	IsDeleted bit DEFAULT(0) NOT NULL,
	IsPublished BIT DEFAULT(0) NOT NULL,
	CONSTRAINT [PKRegistrationFee] PRIMARY KEY (RegistrationFeeId),
	CONSTRAINT [FKRegistrationFeeStudentEnquiry] FOREIGN KEY (StudentEnquiryId) REFERENCES StudentEnquiry(StudentEnquiryId)

)
