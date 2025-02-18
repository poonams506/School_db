-- =============================================
-- Author:    Chaitanya Kasar
-- Create date: 02/04/2024
-- Description:   This stored procedure is used delete teacher subject mapping info
-- =============================================
CREATE PROCEDURE uspTeacherSujectMappingDelete(
 @AcademicYearId INT,
 @TeacherId INT,
 @SubjectId INT
 )
 AS 
 BEGIN 
    SET 
      TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
    SET 
      NOCOUNT ON 
    
      DECLARE @CurrentDateTime DATETIME = GETDATE();
    BEGIN TRY 

	     DELETE FROM TeacherSubjectMapping 
          WHERE 
              TeacherId=@TeacherId
             AND AcademicYearId = @AcademicYearId
             AND SubjectMasterId =  @SubjectId

   
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