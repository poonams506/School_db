CREATE TABLE [dbo].[CBSE_ExamObject]
(
	ExamObjectId BIGINT IDENTITY(1, 1) NOT NULL,
	AcademicYearId SMALLINT,
	ExamMasterId SMALLINT,
	SubjectMasterId INT,
	ObjectName NVARCHAR(200),
	OutOfMarks SMALLINT,
    IsPublished BIT DEFAULT (0) NOT NULL,
	CreatedBy INT,
    CreatedDate DATETIME,
    ModifiedBy INT,
    ModifiedDate DATETIME,
	IsDeleted BIT DEFAULT(0) NOT NULL,

	CONSTRAINT [PKCBSE_ExamObject] PRIMARY KEY (ExamObjectId), 
    CONSTRAINT [FKCBSE_ExamObjectAcademicYear] FOREIGN KEY (AcademicYearId) REFERENCES AcademicYear(AcademicYearId),
    CONSTRAINT [FKCBSE_ExamObjectCBSE_ExamMaster] FOREIGN KEY (ExamMasterId) REFERENCES CBSE_ExamMaster(ExamMasterId),
	CONSTRAINT [FKCBSE_ExamObjectSubjectMaster] FOREIGN KEY (SubjectMasterId) REFERENCES SubjectMaster(SubjectMasterId)
)
