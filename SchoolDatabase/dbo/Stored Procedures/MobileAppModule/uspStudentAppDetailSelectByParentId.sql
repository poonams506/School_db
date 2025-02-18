

-- =============================================
-- Author:    Abhishek Kumar
-- Create date: 17/02/2024
-- Description:  This stored procedure is used to get student Detail By Parent Id for Mobile App.
-- =============================================
CREATE PROC dbo.uspStudentAppDetailSelectByParentId(@UserId INT,@AcademicYearId INT)
AS BEGIN
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 

    SELECT distinct s.StudentId, CONCAT(s.FirstName,' ',s.MiddleName,' ',s.LastName) AS StudentFullName,
       CONCAT(g.GradeName,' - ',d.DivisionName) AS ClassName,
       sgdm.RollNumber AS RollNumber,s.ProfileImageUrl,
	   sgd.SchoolGradeDivisionMatrixId AS ClassId
FROM 
dbo.[User] u JOIN
dbo.[Student] s ON (u.Uname=s.AppAccessMobileNo AND s.IsAppAccess=1) JOIN
dbo.[ParentStudentMapping] sp ON s.StudentId=sp.StudentId JOIN
dbo.[StudentGradeDivisionMapping] sgdm ON s.StudentId=sgdm.StudentId JOIN
dbo.[Grade] g ON sgdm.GradeId=g.GradeId JOIN
dbo.[Division] d ON sgdm.DivisionId=d.DivisionId JOIN
dbo.SchoolGradeDivisionMatrix sgd ON sgd.GradeId=sgdm.GradeId AND sgd.DivisionId=sgdm.DivisionId
WHERE u.UserId=@UserId
AND s.IsDeleted<>1 AND s.IsArchive <> 1 AND sgdm.AcademicYearId=@AcademicYearId AND sgdm.IsDeleted<>1 AND sgd.AcademicYearId = @AcademicYearId and sgd.IsDeleted <> 1

 END 
 TRY 
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
GO
