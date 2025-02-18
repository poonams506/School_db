-- =============================================
-- Author:   Meena Kotkar
-- Create date: 29/08/2023
-- Description:  This stored procedure is used to get Student Name info detail by Id
-- =============================================
CREATE PROC uspStudentNameSelect(
        @AcademicYearId SMALLINT,
        @GradeId SMALLINT,
        @DivisionId SMALLINT
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 
    SELECT 
        s.FirstName + ' ' + s.MiddleName + ' ' + s.LastName AS 'FullName',
        s.StudentId
   FROM Student s 
   INNER JOIN StudentGradeDivisionMapping m ON s.StudentId=m.StudentId
   WHERE
       s.StudentId = m.StudentId 
        AND ISNULL(s.IsDeleted,0)<>1
        AND ISNULL(s.IsArchive,0)<>1
        AND ISNULL(m.IsDeleted,0)<>1 
        AND m.AcademicYearId = @AcademicYearId
        AND m.GradeId = @GradeId
        AND m.DivisionId = @DivisionId
        ORDER BY FullName;
  
END TRY BEGIN CATCH DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
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
@ErrorState END CATCH End
