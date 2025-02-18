CREATE TABLE [dbo].[RegistrationFeeDetails]
(
	RegistrationFeeDetailsId BIGINT IDENTITY(1,1),
	RegistrationFeeId BIGINT,
	FeeParticularId BIGINT,
	StudentEnquiryId INT,
	AcademicYearId SMALLINT,
	InvoiceNumber VARCHAR(100),
	PaidAmount MONEY,
	PaymentTypeId SMALLINT,
	CreatedBy INT,
	CreatedDate DATETIME,
	ModifiedBy INT,
	ModifiedDate DATETIME,
	IsDeleted BIT DEFAULT(0) NOT NULL
	CONSTRAINT [PKRegistrationFeeDetails] PRIMARY KEY (RegistrationFeeDetailsId)
	CONSTRAINT [FKRegistrationFeeDetailsRegistrationFee] FOREIGN KEY (RegistrationFeeId) REFERENCES RegistrationFee(RegistrationFeeId),
	CONSTRAINT [FKRegistrationFeeDetailsFeeParticular] FOREIGN KEY (FeeParticularId) REFERENCES FeeParticular(FeeParticularId),
	CONSTRAINT [FKRegistrationFeeDetailsStudentEnquiry] FOREIGN KEY (StudentEnquiryId) REFERENCES StudentEnquiry(StudentEnquiryId),
	CONSTRAINT [FKRegistrationFeeDetailsAcademicYear] FOREIGN KEY (AcademicYearId) REFERENCES AcademicYear(AcademicYearId)

)
