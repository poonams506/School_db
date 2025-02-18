CREATE TABLE [dbo].[CBSE_ExamMaster]
(
	ExamMasterId SMALLINT IDENTITY(1,1) NOT NULL,
	AcademicYearId SMALLINT,
	ExamTypeId SMALLINT,
	TermId SMALLINT,
	ExamName NVARCHAR(200),
	CreatedBy INT,
	CreatedDate DATETIME,
	ModifiedBy INT,
	ModifiedDate DATETIME,
	IsDeleted BIT DEFAULT (0) NOT NULL,

	CONSTRAINT [PKCBSE_ExamMaster] PRIMARY KEY (ExamMasterId),
	CONSTRAINT [FKCBSE_ExamMasterAcademicYear] FOREIGN KEY (AcademicYearId) REFERENCES AcademicYear(AcademicYearId),
    CONSTRAINT [FKCBSE_ExamMasterCBSE_ExamType] FOREIGN KEY (ExamTypeId) REFERENCES CBSE_ExamType(ExamTypeId),
	CONSTRAINT [FKCBSE_ExamMasterCBSE_Term] FOREIGN KEY (TermId) REFERENCES CBSE_Term(TermId)

)
