CREATE TABLE [dbo].[FeeWavierTypesInstallmentsDetails]
(
	FeeWavierTypesInstallmentsDetailsId BIGINT IDENTITY(1,1),
	AcademicYearId SMALLINT,
	FeeWavierTypeId BIGINT,
	LateFeeStartDate DATETIME,
	DiscountEndDate DATETIME,
	CreatedBy INT, 
	CreatedDate DATETIME, 
	ModifiedBy INT, 
	ModifiedDate DATETIME, 
	IsDeleted BIT DEFAULT(0) NOT NULL,
	CONSTRAINT [PKFeeWavierTypesInstallmentsDetails] PRIMARY KEY CLUSTERED ( [FeeWavierTypesInstallmentsDetailsId] ASC),
	CONSTRAINT [FKFeeWavierTypesInstallmentsDetailsAcademicYear] FOREIGN KEY (AcademicYearId) REFERENCES AcademicYear(AcademicYearId),
	CONSTRAINT [FKFeeWavierTypesInstallmentsDetailsFeeWavierTypeId] FOREIGN KEY (FeeWavierTypeId) REFERENCES FeeWavierTypes(FeeWavierTypeId)
)