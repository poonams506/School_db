-- =============================================
-- Author:    Chaitanya Kasar
-- Create date: 10/04/2024
-- Description:  This stored procedure is used to get area name dropdown
-- =============================================
CREATE PROC uspAreaNameDropdown ( @AcademicYearId SMALLINT) AS BEGIN 
 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 
SELECT 
  AreaId,
  AreaName
FROM 
  dbo.TransportArea
WHERE 
  AcademicYearId= @AcademicYearId AND
  IsDeleted <> 1
   ORDER BY 
    AreaName ASC
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


















