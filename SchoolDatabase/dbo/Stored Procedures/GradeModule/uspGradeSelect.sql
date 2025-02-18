-- =============================================
-- Author:    Swapnil Bhaskar
-- Create date: 13/08/2023
-- Description:  This stored procedure is used to get grade info detail by Id
-- =============================================
CREATE PROC uspGradeSelect(@GradeId INT = NULL) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 
SELECT
GradeId,	
GradeName
FROM 
  Grade 
WHERE 
  GradeId = ISNULL(@GradeId, GradeId) AND IsDeleted<>1  END TRY BEGIN CATCH DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
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
