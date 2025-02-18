-- =============================================
-- Author:    Deepak Walunj
-- Create date: 05/08/2023
-- Description:  This stored procedure is used to get country etc info detail by Id
-- =============================================
CREATE PROC uspCountryMasterSelect AS Begin 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 
SELECT 
  * 
FROM 
  dbo.Country WHERE IsDeleted <> 1 ORDER BY CountryName;
SELECT 
  * 
FROM 
  dbo.State WHERE IsDeleted <> 1 ORDER BY StateName;
SELECT 
  * 
FROM 
  dbo.District WHERE IsDeleted <> 1 ORDER BY DistrictName;
SELECT 
  * 
FROM 
  dbo.Taluka WHERE IsDeleted <> 1 ORDER BY TalukaName;
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
