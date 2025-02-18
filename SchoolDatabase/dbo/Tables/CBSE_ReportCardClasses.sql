CREATE TABLE [dbo].[CBSE_ReportCardClasses]
(
	ReportCardClassesId BIGINT IDENTITY(1, 1) NOT NULL,
	AcademicYearId SMALLINT,
	GradeId SMALLINT,
	DivisionId SMALLINT,
	ExamReportCardNameId BIGINT,
	CreatedBy INT,
    CreatedDate DATETIME,
    ModifiedBy INT,
    ModifiedDate DATETIME,
	IsDeleted BIT DEFAULT(0) NOT NULL,

	CONSTRAINT [PKCBSE_ReportCardClasses] PRIMARY KEY (ReportCardClassesId), 
	CONSTRAINT [FKCBSE_ReportCardClassesAcademicYear] FOREIGN KEY (AcademicYearId) REFERENCES AcademicYear(AcademicYearId),
	CONSTRAINT [FKCBSE_ReportCardClassesGrade] FOREIGN KEY (GradeId) REFERENCES Grade(GradeId),
	CONSTRAINT [FKCBSE_ReportCardClassesDivision] FOREIGN KEY (DivisionId) REFERENCES Division(DivisionId),
	CONSTRAINT [FKCBSE_ReportCardClassesCBSE_ReportCardClasses] FOREIGN KEY (ExamReportCardNameId) REFERENCES CBSE_ExamReportCardName(ExamReportCardNameId)



)
