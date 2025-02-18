-- =============================================
-- Author:    Poonam  b
-- Create date: 13/08/2023
-- Description:  This stored procedure is used to get subject
-- =============================================
Create PROC uspSubjectDropdownSelectByClass(@ClassId [SingleIdType] READONLY,@AcademicYearId INT)
AS Begin 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 

SELECT sgdm.SchoolGradeDivisionMatrixId AS ClassId,sma.SubjectMasterId AS SubjectId,sma.SubjectName AS SubjectName 
FROM dbo.SchoolGradeDivisionMatrix sgdm 
JOIN dbo.SubjectMapping sm ON sgdm.GradeId=sm.GradeId AND sgdm.DivisionId=sm.DivisionId AND sm.AcademicYearId=@AcademicYearId
JOIN dbo.SubjectMaster sma ON sm.SubjectMasterId=sma.SubjectMasterId
JOIN @ClassId c ON c.Id=sgdm.SchoolGradeDivisionMatrixId
WHERE sgdm.IsDeleted<>1 AND sm.IsDeleted<>1 AND sma.IsDeleted<>1 and sgdm.AcademicYearId = @AcademicYearId;


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
