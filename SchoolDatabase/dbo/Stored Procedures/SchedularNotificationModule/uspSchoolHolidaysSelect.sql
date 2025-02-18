--===============================================
-- Author:- Gulave Pramod 
-- Create date:- 28/08/2024
-- Description:- This stored procedure is used to get the holidays before 12 hours from the holiday date for the Student.
-- =============================================
CREATE PROCEDURE [dbo].[uspSchoolHolidaysSelect]
(
    @AcademicYearId INT
)
AS 
BEGIN 
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;
    DECLARE @CurrentDateTime DATETIME=GETDATE()
	BEGIN TRY
 SELECT
            sh.AcademicYearId,
            sh.DayNo,
            sh.CalendarDate,
            sh.HolidayReason
FROM 
            dbo.SchoolHolidays AS sh
		
WHERE
            ISNULL(sh.IsDeleted, 0) <> 1 AND
            DATEADD(HOUR, -12, sh.CalendarDate) <= @CurrentDateTime AND
            sh.CalendarDate > @CurrentDateTime
			AND sh.AcademicYearId=@AcademicYearId

END TRY 
BEGIN CATCH 
        DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        DECLARE @ErrorNumber INT = ERROR_NUMBER();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProcedure NVARCHAR(1000) = ERROR_PROCEDURE();
        EXEC dbo.uspExceptionLogInsert @ErrorLine,
            @ErrorMessage,
            @ErrorNumber,
            @ErrorProcedure,
            @ErrorSeverity,
            @ErrorState;
END CATCH 
END