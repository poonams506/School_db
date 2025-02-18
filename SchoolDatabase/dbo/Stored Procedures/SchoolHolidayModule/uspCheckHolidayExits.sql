-- =============================================
-- Author:   POONAM BHALKE
-- Create date: 07/03/2024
-- Description:  This stored procedure is used to info about exist
-- =============================================

CREATE PROCEDURE [dbo].[uspCheckHolidayExits]
(
    @HolidayDetails dbo.[HolidayDetailsTypes] READONLY,
    @AcademicYearId SMALLINT
)
AS 
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    BEGIN TRY 

        DECLARE @Exist TABLE (CalendarDate DATE, Exist INT);

        INSERT INTO @Exist (CalendarDate, Exist)
        SELECT h.CalendarDate, 
               CASE 
                   WHEN EXISTS (
                       SELECT 1 
                       FROM SchoolHolidays s
                       WHERE CAST(s.CalendarDate as date) = CAST(h.CalendarDate as date)
                       AND s.IsDeleted = 0
                       AND s.AcademicYearId = @AcademicYearId
                   ) THEN 1
                   ELSE 0
               END AS 'Exist'
        FROM @HolidayDetails h;

        SELECT CalendarDate, Exist FROM @Exist;

    END TRY
    BEGIN CATCH 
        
        DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        DECLARE @ErrorNumber INT = ERROR_NUMBER();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProcedure NVARCHAR(1000) = ERROR_PROCEDURE();
        EXEC uspExceptionLogInsert 
            @ErrorLine,
            @ErrorMessage,
            @ErrorNumber,
            @ErrorProcedure,
            @ErrorSeverity,
            @ErrorState;
    END CATCH; -- End of CATCH block
END;

