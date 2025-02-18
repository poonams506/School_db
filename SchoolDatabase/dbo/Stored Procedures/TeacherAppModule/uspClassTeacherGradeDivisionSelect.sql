-- =============================================
-- Author:    Deepak W
-- Create date: 13/08/2023
-- Description:  get class teacher grade and division
-- =============================================
CREATE PROC dbo.uspClassTeacherGradeDivisionSelect
(
@AcademicYearId INT,
@TeacherId INT 
)
AS Begin 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 

SELECT 
  sgdm.SchoolGradeDivisionMatrixId,sgdm.GradeId,sgdm.DivisionId,
  g.GradeName+ ' - '+ d.DivisionName AS ClassName
FROM 
  dbo.SchoolGradeDivisionMatrix sgdm JOIN
  dbo.Grade g ON sgdm.GradeId=g.GradeId JOIN
  dbo.Division d ON sgdm.DivisionId=d.DivisionId JOIN
  dbo.TeacherGradeDivisionMapping tgdm ON tgdm.GradeId=g.GradeId AND tgdm.DivisionId=d.DivisionId
  WHERE sgdm.IsDeleted <> 1 AND tgdm.IsDeleted <> 1 and sgdm.AcademicYearId = @AcademicYearId 
  AND tgdm.TeacherId = @TeacherId AND tgdm.AcademicYearId=@AcademicYearId
  ORDER BY len(g.GradeName+ ' - '+ d.DivisionName),g.GradeName+ ' - '+ d.DivisionName


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
