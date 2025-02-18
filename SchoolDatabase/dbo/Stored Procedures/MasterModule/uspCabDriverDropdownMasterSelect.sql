-- =============================================
-- Author:    Abhishek Kumar
-- Create date: 30/12/2023
-- Description:  This stored procedure is used to get cab driver dropdown list
-- =============================================
CREATE PROC uspCabDriverDropdownMasterSelect 
AS Begin 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 


SELECT 
  cd.CabDriverId AS Id,
  CONCAT(cd.FirstName,' ',cd.MiddleName,' ' ,cd.LastName) AS Value 
  FROM 
  dbo.CabDriver cd
WHERE 
 IsDeleted <> 1
 ORDER BY 
  CONCAT(cd.FirstName,' ',cd.MiddleName,' ' ,cd.LastName) ASC

END TRY

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
@ErrorState END CATCH End
