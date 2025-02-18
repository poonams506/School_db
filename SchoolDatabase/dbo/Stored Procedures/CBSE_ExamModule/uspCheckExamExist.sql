-- =============================================
-- Author:   Tejas Rahane
-- Create date: 29/03/2024
-- Description:  This stored procedure is used to check exam exist or not 
-- =============================================

CREATE PROCEDURE [dbo].[uspCheckExamExist]
(
    @ExamMasterId INT= NULL
)
    AS 
    BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    BEGIN TRY 
    DECLARE @CurrentDateTime DATETIME = GETDATE();

    DECLARE @ExamMappingCount INT;
    DECLARE @ExamObjectCount INT;

    SELECT @ExamMappingCount = COUNT(ExamMasterId) 
    FROM CBSE_ClassExamMapping
    WHERE ExamMasterId = @ExamMasterId and IsDeleted <>1

    SELECT @ExamObjectCount = COUNT(ExamMasterId) 
    FROM CBSE_ExamObject
    WHERE ExamMasterId = @ExamMasterId  and IsDeleted <>1

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
    SELECT @ExamMappingCount as 'ExamMappingCount',
           @ExamObjectCount as 'ExamObjectCount';
   END;

