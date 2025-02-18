-- =============================================
-- Author:    Deepak Walunj
-- Create date: 20/08/2023
-- Description:  This stored procedure is used insert role permission
-- =============================================
CREATE PROCEDURE [dbo].[uspRolePermissionUpsert] (
  @RolePermission dbo.RolePermissionType READONLY,
  @UserId INT
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 

  DECLARE @CurrentDateTime DATETIME = GETDATE();
BEGIN TRY 

     DELETE 
     FROM 
         RolePermission 
     WHERE 
     RoleId IN (SELECT DISTINCT RoleId FROM @RolePermission);

     INSERT INTO RolePermission (RoleId, ModuleId, PermissionId, CreatedBy, CreatedDate)
     SELECT RoleId, ModuleId, PermissionId, @UserId, @CurrentDateTime FROM @RolePermission;

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
@ErrorState END CATCH END

