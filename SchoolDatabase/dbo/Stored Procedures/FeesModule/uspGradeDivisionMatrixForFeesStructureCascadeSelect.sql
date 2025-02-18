-- =============================================
-- Author:    Abhishek Kumar
-- Create date: 13/09/2023
-- Description:  This stored procedure is used to get grade division mapping info details by association of Fees Particular for cascading only
-- =============================================
CREATE PROC uspGradeDivisionMatrixForFeesStructureCascadeSelect 
(@AcademicYearId INT)
AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 

SELECT 
  sgdm.GradeId,sgdm.DivisionId,sgdm.SchoolGradeDivisionMatrixId,
  CONCAT(g.GradeName,'-',d.DivisionName) AS ClassName,
  CASE WHEN fgd.GradeId IS NULL THEN 0  
       ELSE 1 END AS IsAlreadyExist
FROM 
  dbo.SchoolGradeDivisionMatrix sgdm
  INNER JOIN dbo.Grade g ON sgdm.GradeId=g.GradeId
  INNER JOIN dbo.Division d ON sgdm.DivisionId=d.DivisionId
  LEFT  JOIN (SELECT DISTINCT GradeId,DivisionId FROM dbo.FeeParticular WHERE AcademicYearId=@AcademicYearId AND IsDeleted <> 1) fgd 
	    ON sgdm.GradeId=fgd.GradeId AND sgdm.DivisionId=fgd.DivisionId
  WHERE sgdm.IsDeleted <> 1 AND g.IsDeleted<>1 AND d.IsDeleted<>1
  AND sgdm.AcademicYearId = @AcademicYearId;

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
