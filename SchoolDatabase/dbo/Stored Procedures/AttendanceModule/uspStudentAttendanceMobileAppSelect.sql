
-- =============================================
-- Author:    Abhishek Kumar
-- Create date: 17/02/2024
-- Description:  This stored procedure is used to get Student Attendance Detail for Mobile App.
-- =============================================
CREATE PROCEDURE uspStudentAttendanceMobileAppSelect(@StudentId INT,@AcademicYearId INT)
AS BEGIN
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 

	SELECT 
		std.StudentId,
	    std.StudentAttendanceId,
		0 as TeacherId,
		std.AttendanceDateTime,
		std.StatusId
	FROM 
		dbo.StudentAttendance std
    WHERE
		std.StudentId=@StudentId 
		AND std.AcademicYearId=@AcademicYearId
	ORDER BY 
            std.AttendanceDateTime DESC;
 END 
 TRY 
 BEGIN CATCH 
 
 DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();

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
@ErrorState 

END CATCH

END

