-- =============================================
-- Author:    Abhishek Kumar
-- Create date: 06/07/2024
-- Description:  This stored procedure is to count number of Student By Class
-- =============================================
CREATE PROCEDURE [dbo].[uspStudentCountSelect]
(
  @AcademicYearId INT,
  @ClassId INT
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 

   BEGIN TRY 
		
	SELECT COUNT(1)
	FROM dbo.Student s JOIN
	dbo.StudentGradeDivisionMapping sgdm ON s.StudentId=sgdm.StudentId JOIN
	dbo.Grade g ON sgdm.GradeId=g.GradeId JOIN
	dbo.Division d ON sgdm.DivisionId=d.DivisionId JOIN
    dbo.SchoolGradeDivisionMatrix sgm ON g.GradeId=sgm.GradeId AND d.DivisionId=sgm.DivisionId
	WHERE  sgdm.AcademicYearId=@AcademicYearId
	AND (@ClassId=0 OR sgm.SchoolGradeDivisionMatrixId=@ClassId)
	AND s.IsDeleted<>1;
 
  END TRY

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