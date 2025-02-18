-- =============================================
-- Author:    Swapnil Bhaskar
-- Create date: 13/08/2023
-- Description:  This stored procedure is used to get division info detail by Id
-- =============================================
CREATE PROC uspDivisionSelect(@DivisionId INT = NULL) AS Begin 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 
SELECT 
DivisionId,
DivisionName
FROM 
 Division
WHERE 
 DivisionId = ISNULL(@DivisionId, DivisionId) AND IsDeleted<>1 END TRY BEGIN CATCH DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
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
