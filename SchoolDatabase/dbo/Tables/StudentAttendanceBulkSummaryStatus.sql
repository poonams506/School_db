CREATE TABLE [dbo].[StudentAttendanceBulkSummaryStatus]
(
StudentAttendanceSummaryStatusId BIGINT IDENTITY(1, 1), 
AcademicYearId SMALLINT,
GradeId SMALLINT,
DivisionId SMALLINT,
MonthId SMALLINT,
YearId SMALLINT,
IsCompleteStatus BIT DEFAULT(0) NOT NULL,
CreatedBy INT, 
CreatedDate DATETIME, 
ModifiedBy INT, 
ModifiedDate DATETIME, 
IsDeleted BIT DEFAULT(0) NOT NULL,
CONSTRAINT [PKStudentAttendanceBulkSummaryStatus] PRIMARY KEY CLUSTERED ([StudentAttendanceSummaryStatusId] ASC),
CONSTRAINT [FKStudentAttendanceBulkSummaryStatusAcademicYear] FOREIGN KEY (AcademicYearId) REFERENCES AcademicYear(AcademicYearId),
CONSTRAINT [FKStudentAttendanceBulkSummaryStatusGrade] FOREIGN KEY (GradeId) REFERENCES Grade(GradeId),
CONSTRAINT [FKStudentAttendanceBulkSummaryStatusDivision] FOREIGN KEY (DivisionId) REFERENCES Division (DivisionId),
  )
