-- =============================================
-- Author:       Gulave Pramod Sahadu
-- Create date:  24-07-2024
-- Description:  Upsert Procedure for ClassExamMapping
-- =============================================
CREATE PROCEDURE [dbo].[uspClassExamMappingUpsert](
    @ClassExamMappingId BIGINT,
    @AcademicYearId SMALLINT,
    @ExamMasterId INT,
    @UserId INT,
    @ClassId dbo.SingleIdType READONLY 
)
 AS 
 BEGIN 
    SET 
      TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
    SET 
      NOCOUNT ON 
    
      DECLARE @CurrentDateTime DATETIME = GETDATE();
    BEGIN TRY 
	 DELETE FROM CBSE_ClassExamMapping 
  WHERE 
  ExamMasterId = @ExamMasterId
  AND AcademicYearId = @AcademicYearId

    INSERT INTO CBSE_ClassExamMapping(AcademicYearId,ExamMasterId,GradeId,DivisionId, CreatedBy, CreatedDate)
    SELECT @AcademicYearId, @ExamMasterId, m. GradeId, m. DivisionId, @UserId, @CurrentDateTime FROM @ClassId c
	INNER JOIN SchoolGradeDivisionMatrix m ON c.Id = m.SchoolGradeDivisionMatrixId;
   
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
        @ErrorState 
    END CATCH 
    END