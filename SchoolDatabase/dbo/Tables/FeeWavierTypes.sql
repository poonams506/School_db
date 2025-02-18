CREATE TABLE [dbo].[FeeWavierTypes]
(
	FeeWavierTypeId BIGINT IDENTITY(1,1),
	AcademicYearId SMALLINT,
	FeeWavierTypeName NVARCHAR(100) NOT NULL,
	FeeWavierDisplayName NVARCHAR(100) NOT NULL,
	Description NVARCHAR(500) NOT NULL ,
	CategoryId SMALLINT,
	NumberOfInstallments SMALLINT,
	DiscountInPercent NUMERIC(5,4),
	LatePerDayFeeInPercent NUMERIC(5,4),
	IsActive BIT DEFAULT(0) NOT NULL,
	SortBy INT,
	CreatedBy INT, 
	CreatedDate DATETIME, 
	ModifiedBy INT, 
	ModifiedDate DATETIME, 
	IsDeleted BIT DEFAULT(0) NOT NULL,
	CONSTRAINT [PKFeeWavierType] PRIMARY KEY CLUSTERED ( [FeeWavierTypeId] ASC),
	CONSTRAINT [FKFeeWavierTypesAcademicYear] FOREIGN KEY (AcademicYearId) REFERENCES AcademicYear(AcademicYearId)		
)