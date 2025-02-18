CREATE TABLE [dbo].[CBSE_ExamReportCardName]
(
	ExamReportCardNameId BIGINT IDENTITY(1, 1) NOT NULL,
	AcademicYearId SMALLINT,
	ReportCardName NVARCHAR(200),
    Description NVARCHAR(2000),
	IsTwoDifferentExamSection BIT,
	CreatedBy INT,
    CreatedDate DATETIME,
    ModifiedBy INT,
    ModifiedDate DATETIME,
	IsDeleted BIT DEFAULT(0) NOT NULL,

	CONSTRAINT [PKCBSE_ExamReportCardName] PRIMARY KEY (ExamReportCardNameId), 
	CONSTRAINT [FKCBSE_ExamReportCardNameAcademicYear] FOREIGN KEY (AcademicYearId) REFERENCES AcademicYear(AcademicYearId)

)
