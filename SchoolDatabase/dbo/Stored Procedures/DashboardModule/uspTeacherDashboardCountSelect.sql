-- =============================================
-- Author:    Abhishek Kumar
-- Create date: 28/04/2024
-- Description:  This stored procedure is used to get teacher dashboard count
-- =============================================
CREATE PROC dbo.uspTeacherDashboardCountSelect(@AcademicYearId SMALLINT, @TeacherId BIGINT) AS Begin 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 

DECLARE @TotalCount INT, @GirlsCount INT, @BoysCount INT;
SELECT
@TotalCount = COUNT(s.StudentId)
FROM dbo.Student s JOIN
dbo.StudentGradeDivisionMapping m ON m.StudentId = s.StudentId  JOIN
dbo.TeacherGradeDivisionMapping t ON t.GradeId=m.GradeId AND t.DivisionId=m.DivisionId
WHERE s.IsDeleted <> 1 and s.IsArchive <> 1 AND m.AcademicYearId = @AcademicYearId and m.IsDeleted <> 1
AND t.AcademicYearId = @AcademicYearId
AND t.TeacherId = @TeacherId;

SELECT
@GirlsCount = COUNT(s.StudentId)
FROM dbo.Student s JOIN
dbo.StudentGradeDivisionMapping m ON m.StudentId = s.StudentId  JOIN
dbo.TeacherGradeDivisionMapping t ON t.GradeId=m.GradeId AND t.DivisionId=m.DivisionId
WHERE s.IsDeleted <> 1 and s.IsArchive <> 1 AND m.AcademicYearId = @AcademicYearId and m.IsDeleted <> 1
AND t.AcademicYearId = @AcademicYearId
AND t.TeacherId = @TeacherId AND s.Gender = 'F'


SELECT
@BoysCount = COUNT(s.StudentId)
FROM dbo.Student s JOIN
dbo.StudentGradeDivisionMapping m ON m.StudentId = s.StudentId  JOIN
dbo.TeacherGradeDivisionMapping t ON t.GradeId=m.GradeId AND t.DivisionId=m.DivisionId
WHERE s.IsDeleted <> 1 and s.IsArchive <> 1 AND m.AcademicYearId = @AcademicYearId and m.IsDeleted <> 1
AND t.AcademicYearId = @AcademicYearId
AND t.TeacherId = @TeacherId AND s.Gender = 'M'

SELECT @TotalCount AS TotalCount, @GirlsCount AS GirlsCount, @BoysCount AS BoysCount



DECLARE @TodaysAttendance decimal(18,2)
DECLARE @MonthlyAttendance decimal(18,2)
DECLARE @TillDateAttendance decimal(18,2)


--Today's Attendance %

SELECT @TodaysAttendance = ISNULL(SUM(CASE WHEN a.StatusId =1 THEN 1
				WHEN a.StatusId = 2 THEN 0.50 ELSE 0 END)/ COUNT(a.StudentAttendanceId) * 100,0)
FROM dbo.StudentAttendance a
INNER JOIN dbo.StudentGradeDivisionMapping m ON a.StudentId = m.StudentId
INNER JOIN dbo.TeacherGradeDivisionMapping t ON m.GradeId=t.GradeId AND m.DivisionId=t.DivisionId
WHERE a.AttendanceDateTime = CAST(GETDATE() AS DATE) 
AND a.AcademicYearId = @AcademicYearId
and a.IsDeleted <> 1
and t.IsDeleted <> 1
and t.AcademicYearId = @AcademicYearId
and m.IsDeleted <> 1
AND m.AcademicYearId=@AcademicYearId;


--Till Date Attendance in AY

SELECT @TillDateAttendance = SUM(CASE WHEN a.StatusId = 1 THEN 1  
WHEN a.StatusId = 2 THEN 0.50 ELSE 0 END)  / COUNT(a.StudentAttendanceId) * 100 
FROM dbo.StudentAttendance a
INNER JOIN dbo.StudentGradeDivisionMapping m ON a.StudentId = m.StudentId
INNER JOIN dbo.TeacherGradeDivisionMapping t ON m.GradeId=t.GradeId AND m.DivisionId=t.DivisionId
WHERE a.AcademicYearId = @AcademicYearId
and a.IsDeleted <> 1
and t.IsDeleted <> 1
and t.AcademicYearId = @AcademicYearId
and m.IsDeleted <> 1
AND m.AcademicYearId=@AcademicYearId;

--Current Month Attendance%

SELECT @MonthlyAttendance = ISNULL(SUM(CASE WHEN a.StatusId = 1 THEN 1  
WHEN a.StatusId = 2 THEN 0.50 ELSE 0 END)  / count(a.StudentAttendanceId) * 100,0)
FROM dbo.StudentAttendance a
INNER JOIN dbo.StudentGradeDivisionMapping m on a.StudentId = m.StudentId
WHERE a.AttendanceDateTime >=  CAST(DATEADD(DD,-(DAY(GETDATE() -1)), GETDATE()) AS DATE)
AND a.AttendanceDateTime <=  CAST(DATEADD(DD,-(DAY(GETDATE())), DATEADD(MM, 1, GETDATE())) AS DATE)
AND a.AcademicYearId = @AcademicYearId 
and a.IsDeleted <> 1
and m.IsDeleted <> 1
AND m.AcademicYearId=@AcademicYearId;;

SELECT @TodaysAttendance AS TodaysAttendance, @MonthlyAttendance AS MonthlyAttendance, @TillDateAttendance AS TillDateAttendance



END TRY BEGIN CATCH DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
DECLARE @ErrorState INT = ERROR_STATE();
DECLARE @ErrorNumber INT = ERROR_NUMBER();
DECLARE @ErrorLine INT = ERROR_LINE();
DECLARE @ErrorProcedure NVARCHAR(1000) = ERROR_PROCEDURE();
EXEC uspExceptionLogInsert @ErrorLine,
@ErrorMessage,
@ErrorNumber,
@ErrorProcedure,
@ErrorSeverity,
@ErrorState END CATCH
END
GO
