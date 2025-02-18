-- =============================================
-- Author:    Deepak Walunj
-- Create date: 20/08/2023
-- Description:  This stored procedure is used to get permissions
-- =============================================
CREATE PROCEDURE [dbo].[uspPermissionSelect]
AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 
SELECT
  PermissionId,	
  Name AS 'PermissionName',
  PermissionKey AS 'PermissionNameKey'
FROM 
  Permission 
WHERE 
  IsDeleted<>1  
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

