CREATE TYPE [dbo].[StudentAttendanceType] AS TABLE
(
    StudentId BIGINT ,
	StatusId TINYINT,
	Reason NVARCHAR (100)
)
