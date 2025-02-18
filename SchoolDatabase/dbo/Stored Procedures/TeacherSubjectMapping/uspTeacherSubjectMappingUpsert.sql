-- =============================================
-- Author:    Chaitanya Kasar
-- Create date: 05/03/2024
-- Description:   This stored procedure is used insert techer subject mapping info
-- =============================================
CREATE PROCEDURE uspTeacherSubjectMappingUpsert(
 @TeacherSubjectMappingId INT,
 @AcademicYearId INT,
 @TeacherId INT,
 @LecturePerWeek INT,
 @Subject dbo.SubjectMappingType READONLY,
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
  
  DELETE FROM dbo.TeacherSubjectMapping 
  WHERE 
  TeacherId = @TeacherId
  AND AcademicYearId = @AcademicYearId
  DELETE FROM TeacherAcademicDetail 
  WHERE 
  TeacherId = @TeacherId
  AND AcademicYearId = @AcademicYearId

    INSERT INTO dbo.TeacherSubjectMapping(AcademicYearId,TeacherId, SubjectMasterId, CreatedBy, CreatedDate)
    SELECT @AcademicYearId, @TeacherId, s.SubjectMasterId, @UserId, @CurrentDateTime FROM @Subject s;

    INSERT INTO TeacherAcademicDetail(AcademicYearId,TeacherId, LecturePerWeek, CreatedBy, CreatedDate)
    SELECT @AcademicYearId, @TeacherId, @LecturePerWeek, @UserId, @CurrentDateTime 
   
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