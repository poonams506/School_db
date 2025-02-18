-- =============================================
-- Author:    Chaitanya Kasar
-- Create date: 06/03/2024
-- Description:  This stored procedure is used to get  subject dropdown select by class
-- =============================================
CREATE PROC uspSubjectDropDownSelect 
 @GradeId INT,
 @DivisionId INT,
 @AcademicYearId INT
AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 
SELECT 
 s.SubjectMasterId as SubjectId,
 sm. SubjectName,
 g.GradeId,
 d.DivisionId,
 s.AcademicYearId
FROM 
  dbo.SubjectMapping s
  INNER JOIN dbo.SubjectMaster AS sm ON s.SubjectMasterId =sm.SubjectMasterId
  INNER JOIN dbo.Grade g ON s.GradeId = g.GradeId
  INNER JOIN dbo.Division d ON s.DivisionId = d.DivisionId

WHERE 
  s.IsDeleted <> 1
  AND sm.IsDeleted <> 1
  AND g.GradeId = @GradeId
  AND d.DivisionId = @DivisionId
  AND s.AcademicYearId=@AcademicYearId
  ORDER BY sm.SubjectName;
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
