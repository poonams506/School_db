-- =============================================
-- Author:    Deepak Walunj
-- Create date: 05/08/2023
-- Description:  This stored procedure is used to get grade division info detail by Id
-- =============================================
CREATE PROC uspGradeDivisionMasterSelect AS Begin 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 
SELECT 
  * 
FROM 
  dbo.Grade WHERE IsDeleted <> 1
        ORDER BY
            TRY_CAST(GradeName AS INT), GradeName;
SELECT 
  * 
FROM 
  dbo.Division WHERE IsDeleted <> 1 
  ORDER BY DivisionName;

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
