CREATE TABLE [dbo].[CBSE_ReportCardExam]
(
	ReportCardExamId BIGINT IDENTITY(1, 1) NOT NULL,
	AcademicYearId SMALLINT,
	ExamMasterId SMALLINT,
	TermId SMALLINT,
	ExamReportCardNameId BIGINT,
	CreatedBy INT,
    CreatedDate DATETIME,
    ModifiedBy INT,
    ModifiedDate DATETIME,
	IsDeleted BIT DEFAULT(0) NOT NULL,

	CONSTRAINT [PKCBSE_ReportCardExam] PRIMARY KEY (ReportCardExamId), 
	CONSTRAINT [FKCBSE_ReportCardExamAcademicYear] FOREIGN KEY (AcademicYearId) REFERENCES AcademicYear(AcademicYearId),
	CONSTRAINT [FKCBSE_ReportCardExamCBSE_ExamMaster] FOREIGN KEY (ExamMasterId) REFERENCES CBSE_ExamMaster(ExamMasterId),
	CONSTRAINT [FKCBSE_ReportCardExamCBSE_Term] FOREIGN KEY (TermId) REFERENCES CBSE_Term(TermId),
	CONSTRAINT [FKCBSE_ReportCardExamCBSE_ExamReportCardName] FOREIGN KEY (ExamReportCardNameId) REFERENCES CBSE_ExamReportCardName(ExamReportCardNameId),

)
