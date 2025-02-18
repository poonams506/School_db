CREATE TABLE [dbo].[StudentAttendance]
(
StudentAttendanceId BIGINT IDENTITY(1, 1), 
AcademicYearId SMALLINT,
GradeId SMALLINT,
DivisionId SMALLINT,
StudentId BIGINT,
AttendanceDateTime DATETIME,
StatusId TINYINT,
IsLeaveApproved BIT DEFAULT(0) NOT NULL,
Reason NVARCHAR(1000),
CreatedBy INT, 
CreatedDate DATETIME, 
ModifiedBy INT, 
ModifiedDate DATETIME, 
IsDeleted BIT DEFAULT(0) NOT NULL,
CONSTRAINT [PKStudentAttendance] PRIMARY KEY CLUSTERED ([StudentAttendanceId] ASC),
  CONSTRAINT [FKStudentAttendanceAcademicYear] FOREIGN KEY (AcademicYearId) REFERENCES AcademicYear(AcademicYearId),
  CONSTRAINT [FKStudentAttendanceStudent] FOREIGN KEY (StudentId) REFERENCES Student( StudentId),
   CONSTRAINT [FKStudentAttendanceGrade] FOREIGN KEY (GradeId) REFERENCES Grade(GradeId),
  CONSTRAINT [FKStudentAttendanceDivision] FOREIGN KEY (DivisionId) REFERENCES Division (DivisionId),
)

