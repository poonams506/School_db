-- =============================================
-- Author:    Poonam Bhalke
-- Create date: 20/02/2024
-- Description:  This stored procedure is used to get SchoolHoliday info detail by Id
-- =============================================
CREATE PROCEDURE [dbo].[uspWeeklyDayOffSelect]
(
    @AcademicYearId INT
)
AS 
BEGIN 
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;
    
    BEGIN TRY 
        SELECT
             w.WeeklyOffId,
             w.AcademicYearId,
             w.DayNo
            
        FROM 
            dbo.WeeklyOff AS w
      
        WHERE
            w.AcademicYearId = @AcademicYearId  AND w.IsDeleted <> 1

    END TRY 
    
    BEGIN CATCH 
        DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        DECLARE @ErrorNumber INT = ERROR_NUMBER();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProcedure NVARCHAR(1000) = ERROR_PROCEDURE();
        EXEC uspExceptionLogInsert @ErrorLine, @ErrorMessage, @ErrorNumber, @ErrorProcedure, @ErrorSeverity, @ErrorState;
    END CATCH 
END
 

