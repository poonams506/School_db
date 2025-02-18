-- =============================================
-- Author:   Prathamesh Ghule
-- Create date: 21/03/2024
-- Description:  This stored procedure is used ClassAttendanceDate data
-- =============================================
CREATE PROCEDURE [dbo].[uspClassAttendanceDateExitsReportSelect] (
  @TakenOn DATETIME = NULL,
    @AcademicYearId INT=null
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 
   	 DECLARE @IsSchoolHoliday INT;
	
BEGIN TRY
	 SELECT @IsSchoolHoliday = CASE WHEN EXISTS (
            SELECT 1
            FROM dbo.udfGetSchoolHolidays(@AcademicYearId) AS sh
            WHERE sh.Holidays = CONVERT(DATETIME,@TakenOn,105)
        ) THEN 1 ELSE  0 END

		select @IsSchoolHoliday AS 'IsSchoolHoliday';
	 
END TRY
BEGIN CATCH DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
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
@ErrorState END CATCH END



