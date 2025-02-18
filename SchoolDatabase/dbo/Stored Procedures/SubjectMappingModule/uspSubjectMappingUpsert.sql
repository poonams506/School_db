-- =============================================
-- Author:    Chaitanya Kasar
-- Create date: 04/03/2024
-- Description:   This stored procedure is used insert subject mapping info
-- =============================================
CREATE PROCEDURE uspSubjectMappingUpsert(
 @SubjectMappingId INT,
 @AcademicYearId INT,
 @GradeId INT,
 @DivisionId INT,
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
  UPDATE sm
        SET sm.SubjectMasterId = s.SubjectMasterId
        FROM SubjectMapping sm
        INNER JOIN @Subject s
            ON sm.GradeId = @GradeId
            AND sm.DivisionId = @DivisionId
            AND sm.AcademicYearId = @AcademicYearId
            AND sm.SubjectMasterId = s.SubjectMasterId;

    INSERT INTO SubjectMapping(AcademicYearId,GradeId, DivisionId, SubjectMasterId, CreatedBy, CreatedDate)
    SELECT @AcademicYearId, @GradeId, @DivisionId, s.SubjectMasterId, @UserId, @CurrentDateTime FROM @Subject s
	 WHERE NOT EXISTS (
            SELECT 1
            FROM SubjectMapping sm
            WHERE sm.GradeId = @GradeId
              AND sm.DivisionId = @DivisionId
              AND sm.AcademicYearId = @AcademicYearId
              AND sm.SubjectMasterId = s.SubjectMasterId
        );

   
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