CREATE TABLE [dbo].[FeeParticular]
(
	FeeParticularId BIGINT IDENTITY(1,1),
	AcademicYearId SMALLINT,
	GradeId SMALLINT,
	DivisionId SMALLINT ,
	ParticularName NVARCHAR(100) NOT NULL,
	Amount MONEY,
	IsDiscountApplicable BIT DEFAULT(0) NOT NULL,
	IsRTEApplicable BIT DEFAULT(0) NOT NULL,
	IsPublished BIT DEFAULT(0) NOT NULL,
	SortBy INT,
	CreatedBy INT, 
    CreatedDate DATETIME, 
    ModifiedBy INT, 
    ModifiedDate DATETIME, 
    IsDeleted BIT DEFAULT(0) NOT NULL,
	CONSTRAINT [PKFeeParticular] PRIMARY KEY CLUSTERED ([FeeParticularId] ASC),
	CONSTRAINT [FKFeeParticularAcademicYear] FOREIGN KEY (AcademicYearId) REFERENCES AcademicYear(AcademicYearId),
	CONSTRAINT [FKFeeParticularGrade] FOREIGN KEY (GradeId) REFERENCES Grade(GradeId),
	CONSTRAINT [FKFeeParticularDivision] FOREIGN KEY (DivisionId) REFERENCES Division(DivisionId)	
)