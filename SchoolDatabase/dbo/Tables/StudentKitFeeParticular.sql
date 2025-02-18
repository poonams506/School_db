CREATE TABLE [dbo].[StudentKitFeeParticular]
(
	FeeParticularId BIGINT IDENTITY(1,1),
	AcademicYearId SMALLINT,
	GradeId SMALLINT,
	DivisionId SMALLINT ,
	ParticularName NVARCHAR(100) NOT NULL,
	Amount MONEY,
	IsPublished BIT DEFAULT(0) NOT NULL,
	SortBy INT,
	CreatedBy INT, 
    CreatedDate DATETIME, 
    ModifiedBy INT, 
    ModifiedDate DATETIME, 
    IsDeleted BIT DEFAULT(0) NOT NULL,
	CONSTRAINT [PKStudentKitFeeParticular] PRIMARY KEY CLUSTERED ([FeeParticularId] ASC),
	CONSTRAINT [FKStudentKitFeeParticularAcademicYear] FOREIGN KEY (AcademicYearId) REFERENCES AcademicYear(AcademicYearId),
	CONSTRAINT [FKStudentKitFeeParticularGrade] FOREIGN KEY (GradeId) REFERENCES Grade(GradeId),
	CONSTRAINT [FKStudentKitFeeParticularDivision] FOREIGN KEY (DivisionId) REFERENCES Division(DivisionId)	
)