CREATE PROC dbo.uspClassTeacherClassSubjectSelect
(
@AcademicYearId INT,
@TeacherId INT,
@ClassId INT
)
AS Begin 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 

SELECT 
  smt.SubjectMasterId,smt.SubjectName
FROM 
  dbo.SchoolGradeDivisionMatrix sgdm JOIN
  dbo.Grade g ON sgdm.GradeId=g.GradeId JOIN
  dbo.Division d ON sgdm.DivisionId=d.DivisionId JOIN
  dbo.TeacherGradeDivisionMapping tgdm ON tgdm.GradeId=g.GradeId AND tgdm.DivisionId=d.DivisionId JOIN
  dbo.SubjectMapping sm ON sm.GradeId=g.GradeId AND sm.DivisionId=d.DivisionId JOIN
  dbo.SubjectMaster smt ON sm.SubjectMasterId=smt.SubjectMasterId JOIN
  dbo.TeacherSubjectMapping tsm ON tsm.SubjectMasterId=smt.SubjectMasterId
  WHERE sgdm.IsDeleted <> 1 and sgdm.AcademicYearId = @AcademicYearId 
  AND tgdm.TeacherId = @TeacherId AND tgdm.AcademicYearId=@AcademicYearId
  AND sm.AcademicYearId=@AcademicYearId AND sm.IsDeleted=0
  AND tsm.TeacherId=@TeacherId AND tsm.AcademicYearId=@AcademicYearId
  AND sgdm.SchoolGradeDivisionMatrixId=@ClassId
  ORDER BY smt.SubjectName


 END 

 TRY 
 BEGIN CATCH DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();

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
@ErrorState END CATCH END
GO
