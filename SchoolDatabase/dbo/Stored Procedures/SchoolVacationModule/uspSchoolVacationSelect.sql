-- =============================================
-- Author:   POONAM BHALKE
-- Create date: 07/03/2024
-- Description:  This stored procedure is used to get school event  data
-- =============================================
CREATE PROCEDURE uspSchoolVacationSelect 
(
    @SchoolVacationId INT
)
AS 
BEGIN 
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    BEGIN TRY 
        SELECT 
            sv.SchoolVacationId,
            sv.AcademicYearId,
            sv.VacationName,
            sv.StartDate,
            sv.EndDate
        FROM 
            SchoolVacation AS sv
        WHERE 
            sv.SchoolVacationId = @SchoolVacationId 
            AND ISNULL(sv.IsDeleted, 0) <> 1;
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
    END CATCH 
END
