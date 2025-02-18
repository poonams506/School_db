-- =============================================
-- Author:    Shambala Apugade
-- Create date: 27/08/2023
-- Description:  This stored procedure is used to get Fee Particular info detail by Id
-- =============================================
CREATE PROCEDURE uspStudentKitFeeParticularSelect
(
@ClassId INT,
@AcademicYearId SMALLINT
)
AS BEGIN
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 


SELECT g.GradeName,g.GradeId,d.DivisionName,
       d.DivisionId,sgdm.SchoolGradeDivisionMatrixId AS ClassId,
       CONCAT(g.GradeName,'-', d.DivisionName) AS ClassName
FROM dbo.SchoolGradeDivisionMatrix sgdm
JOIN dbo.Grade g ON sgdm.GradeId=g.GradeId
JOIN dbo.Division d ON sgdm.DivisionId=d.DivisionId
WHERE sgdm.SchoolGradeDivisionMatrixId=@ClassId AND sgdm.AcademicYearId = @AcademicYearId;

-- FeeParticular list
SELECT
    f.FeeParticularId,
    sgdm.SchoolGradeDivisionMatrixId AS ClassId,
    f.ParticularName,
    f.Amount,
    f.IsPublished AS IsPublish,
    f.SortBy,
    CASE WHEN fp.StudentKitFeePaymentDetailId IS NULL THEN 0
         ELSE 1 END AS IsFeePaymentAlreadyDone 

FROM
     dbo.StudentKitFeeParticular f
      OUTER APPLY (SELECT TOP (1) fp.StudentKitFeePaymentDetailId FROM dbo.StudentKitFeePaymentDetails fp WHERE
                    fp.FeeParticularId=f.FeeParticularId AND fp.AcademicYearId=@AcademicYearId
                    AND fp.IsDeleted<>1 ORDER BY fp.StudentKitFeePaymentDetailId) AS fp
     
     INNER JOIN dbo.Grade g ON f.GradeId = g.GradeId
     INNER JOIN dbo.Division d ON f.DivisionId = d.DivisionId
	 INNER JOIN dbo.SchoolGradeDivisionMatrix sgdm ON g.GradeId = sgdm.GradeId AND d.DivisionId = sgdm.DivisionId AND f.AcademicYearId = sgdm.AcademicYearId
    
WHERE
     sgdm.SchoolGradeDivisionMatrixId = @ClassId 
     AND f.IsDeleted<>1
     AND f.AcademicYearId = @AcademicYearId


END TRY 
BEGIN CATCH 

DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
DECLARE @ErrorState INT = ERROR_STATE();
DECLARE @ErrorNumber INT = ERROR_NUMBER();
DECLARE @ErrorLine INT = ERROR_LINE();
DECLARE @ErrorProcedure NVARCHAR(1000) = ERROR_PROCEDURE();

EXEC dbo.uspExceptionLogInsert @ErrorLine=@ErrorLine, 
@ErrorMessage=@ErrorMessage, 
@ErrorNumber=@ErrorNumber, 
@ErrorProcedure=@ErrorProcedure, 
@ErrorSeverity=@ErrorSeverity, 
@ErrorState=@ErrorState 

END CATCH 

END





