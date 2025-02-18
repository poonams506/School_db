CREATE TABLE [dbo].[CBSE_ExamResult]
(
	CBSE_ExamResultId SMALLINT IDENTITY(1,1),
	AcademicYearId SMALLINT,
	StudentId BIGINT,
	ExamObjectId BIGINT ,
	OutOfMarks SMALLINT,
	ActualMarks DECIMAL(18,2),
	TotalMarks DECIMAL(18,2),
	Percentage DECIMAL (18,2),
	Grade NVARCHAR(10),
    CreatedBy INT,
    CreatedDate DATETIME,
    ModifiedBy INT,
    ModifiedDate DATETIME,
    IsDeleted BIT DEFAULT (0) NOT NULL 

	    CONSTRAINT [PKCBSE_ExamResultId] PRIMARY KEY (CBSE_ExamResultId), 
	   CONSTRAINT [FKCBSE_ExamResultAcademicYear] FOREIGN KEY (AcademicYearId) REFERENCES AcademicYear(AcademicYearId),
	   CONSTRAINT [FKCBSE_ExamResultStudent] FOREIGN KEY (StudentId) REFERENCES Student(StudentId),
	   CONSTRAINT [FKCBSE_ExamResultCBSE_ExamObject] FOREIGN KEY (ExamObjectId) REFERENCES CBSE_ExamObject(ExamObjectId)


)


