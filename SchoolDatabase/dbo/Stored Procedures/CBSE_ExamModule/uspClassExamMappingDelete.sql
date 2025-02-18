--===============================================
-- Author:- Gulave Pramod
-- Create date:- 24-07-2024
-- Description:- This stored procedure is used delete Class Exam Mapping Data
-- =============================================
CREATE PROCEDURE [dbo].[uspClassExamMappingDelete] (
    @AcademicYearId INT,
    @ExamMasterId BIGINT,
	@GradeId INT,
    @DivisionId INT
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 

  DECLARE @CurrentDateTime DATETIME = GETDATE();
	 
  BEGIN TRY
      DELETE FROM CBSE_ClassExamMapping 
          WHERE 
           AcademicYearId = @AcademicYearId
          AND ExamMasterId =  @ExamMasterId
          AND GradeId = @GradeId
          AND DivisionId = @DivisionId
    END TRY
    BEGIN CATCH
      -- Log the exception
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