CREATE TABLE [dbo].[CBSE_MarksGradeRelation]
(
	MarksGradeRelationId BIGINT IDENTITY(1,1) NOT NULL,
	AcademicYearId SMALLINT,
	MinMark INT,
	MaxMark INT,
	Grade NVARCHAR(5),
	CreatedBy INT,
    CreatedDate DATETIME,
    ModifiedBy INT,
    ModifiedDate DATETIME,
	IsDeleted BIT DEFAULT(0) NOT NULL,
	CONSTRAINT [PKCBSE_MarksGradeRelation] PRIMARY KEY (MarksGradeRelationId), 
    CONSTRAINT [FKCBSE_MarksGradeRelationAcademicYear] FOREIGN KEY (AcademicYearId) REFERENCES AcademicYear(AcademicYearId),
)
