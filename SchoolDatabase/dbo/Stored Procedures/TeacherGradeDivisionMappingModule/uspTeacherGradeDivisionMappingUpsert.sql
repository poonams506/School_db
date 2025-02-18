-- =============================================
-- Author:    Chaitanya Kasar
-- Create date: 19/02/2024
-- Description:   This stored procedure is used insert  teacher grade division mapping info
-- =============================================
CREATE PROCEDURE uspTeacherGradeDivisionMappingUpsert(
 @TeacherGradeDivisionMappingId INT,
 @AcademicYearId INT,
 @GradeId INT,
 @DivisionId INT,
 @Teacher dbo.TeacherType READONLY,
 @UserId INT
 )
 AS 
 BEGIN 
    SET 
      TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
    SET 
      NOCOUNT ON 
    
      DECLARE @CurrentDateTime DATETIME = GETDATE();
    BEGIN TRY 
	 DELETE FROM TeacherGradeDivisionMapping 
  WHERE 
  GradeId = @GradeId
  AND DivisionId = @DivisionId
  AND AcademicYearId = @AcademicYearId

    INSERT INTO TeacherGradeDivisionMapping(AcademicYearId,GradeId, DivisionId, TeacherId, CreatedBy, CreatedDate)
    SELECT @AcademicYearId, @GradeId, @DivisionId, t.TeacherId, @UserId, @CurrentDateTime FROM @Teacher t;
   
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