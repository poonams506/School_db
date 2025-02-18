-- ==============================================================
-- Author:    Deepak W
-- Create date: 31/03/2024
-- Description:  This stored procedure is used to pass or fail student
-- ==============================================================

CREATE PROC uspStudentPassOrFailUpdate (
@AcademicYearId INT,
@IsPass INT,
@StudentListString VARCHAR(MAX),
@UserId INT
) AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON
     DECLARE @CurrentDateTime DATETIME = GETDATE();
    BEGIN TRY
     
       UPDATE StudentGradeDivisionMapping 
       SET IsPassed = @IsPass,
           ModifiedBy=@UserId,
             ModifiedDate=@CurrentDateTime
       WHERE AcademicYearId = @AcademicYearId
       AND StudentId IN (SELECT value FROM STRING_SPLIT(@StudentListString, ','))
                
    END TRY
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
            @ErrorState;
    END CATCH
END

