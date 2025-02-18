-- Author:    Poonam Bhalke
-- Create date: 20/02/2024
-- Description:  This stored procedure is used to get SchoolHoliday info detail by Id
-- =============================================
CREATE PROCEDURE [dbo].[uspSchoolHolidaySelect]
(
    @SchoolHolidayId INT
)
AS 
BEGIN 
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;
    
    BEGIN TRY 
        SELECT
            sh.SchoolHolidayId,
            sh.AcademicYearId,
            sh.DayNo,
            sh.CalendarDate,
            sh.HolidayReason
        FROM 
            dbo.SchoolHolidays AS sh
      
        WHERE
            sh.SchoolHolidayId = @SchoolHolidayId AND
            ISNULL(sh.IsDeleted, 0) <> 1;


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
 
