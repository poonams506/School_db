--===============================================
-- Author:    Poonam Shinde
-- Create date: 28/11/2024
-- Description: This stored procedure inserts a record into StudentAttendanceBulkSummaryStatus
-- =============================================
CREATE PROCEDURE [dbo].[uspStudentAttendanceStatusInsert]
    @AcademicYearId SMALLINT,
    @GradeId SMALLINT,
    @DivisionId SMALLINT,
    @YearId INT,
    @MonthId INT,
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StartDate DATE = DATEFROMPARTS(@YearId, @MonthId, 1);
    DECLARE @EndDate DATE = EOMONTH(@StartDate);
    DECLARE @CurrentDateTime DATETIME = GETDATE();

    BEGIN TRY
        INSERT INTO StudentAttendanceBulkSummaryStatus 
            (AcademicYearId, GradeId, DivisionId, YearId, MonthId, IsCompleteStatus, CreatedBy, CreatedDate)
        VALUES 
            (@AcademicYearId, @GradeId, @DivisionId, @YearId, @MonthId,1, @UserId, @CurrentDateTime);
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
END;
