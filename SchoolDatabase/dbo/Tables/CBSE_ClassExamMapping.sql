CREATE TABLE [dbo].[CBSE_ClassExamMapping]
(
	ClassExamMappingId BIGINT IDENTITY(1,1) NOT NULL,
	AcademicYearId SMALLINT,
	ExamMasterId SMALLINT,
	GradeId SMALLINT,
	DivisionId SMALLINT,
	CreatedBy INT,
    CreatedDate DATETIME,
    ModifiedBy INT,
    ModifiedDate DATETIME,
	IsDeleted BIT DEFAULT(0) NOT NULL,

	CONSTRAINT [PKCBSE_ClassExamMapping] PRIMARY KEY (ClassExamMappingId),
	CONSTRAINT [FKCBSE_ClassExamMappingAcademicYear] FOREIGN KEY (AcademicYearId) REFERENCES AcademicYear(AcademicYearId),
    CONSTRAINT [FKCBSE_ClassExamMappingCBSE_ExamMaster] FOREIGN KEY (ExamMasterId) REFERENCES CBSE_ExamMaster(ExamMasterId),
	CONSTRAINT [FKCBSE_ClassExamMappingGrade] FOREIGN KEY (GradeId) REFERENCES Grade(GradeId),
	CONSTRAINT [FKCBSE_ClassExamMappingDivision] FOREIGN KEY (DivisionId) REFERENCES Division(DivisionId)

)
