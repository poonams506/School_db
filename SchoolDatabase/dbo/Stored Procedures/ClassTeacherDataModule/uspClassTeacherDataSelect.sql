-- =============================================
-- Author:    Poonam  Bhalke
-- Create date: 06/03/2024
-- Description:  This stored procedure is used to get ClassTeacher info detail by Id
-- =============================================
CREATE PROC uspClassTeacherDataSelect
(
	@AcademicYearId SMALLINT,
	@UserId INT
)
AS Begin 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 

 SELECT 
     t.GradeId,
     t.DivisionId
FROM 
	 dbo.TeacherGradeDivisionMapping AS t
	 INNER JOIN [UserRole] AS u ON t.TeacherId = u.RefId AND RoleId=3
WHERE 
	t.AcademicYearId = @AcademicYearId  AND
	u.UserId = @UserId 
	AND t.IsDeleted <> 1
	AND u.IsDeleted <>1

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
