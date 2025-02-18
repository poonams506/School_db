-- =============================================
-- Author:    Deepak Walunj
-- Create date: 20/08/2023
-- Description:  This stored procedure is used to get role permission
-- =============================================
CREATE PROCEDURE [dbo].[uspRolePermissionSelect](@RoleId INT)
AS
Begin
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;                              
	SET NOCOUNT ON;  

	BEGIN TRY 

		SELECT 
		     RoleId, 
		     Name AS 'RoleName',
			 RoleKey AS 'RoleNameKey'
		FROM 
			 Role 
		WHERE IsDeleted <> 1 AND RoleId = @RoleId;

		SELECT 
		     m.ModuleId, 
		     m.Name AS 'ModuleName',
			 m.ModuleKey AS 'ModuleNameKey',
			 m.MenuUrl
		FROM 
			 Module m JOIN
			 RolePermission rp ON
			 m.ModuleId = rp.ModuleId
		WHERE m.IsDeleted <> 1 AND rp.IsDeleted <> 1 AND rp.RoleId = @RoleId;

		SELECT 
		     rp.ModuleId, 
		     rp.PermissionId,
			 rp.RoleId
		FROM 
			 RolePermission rp
		WHERE rp.IsDeleted <> 1 AND rp.RoleId = @RoleId;

       



	 END TRY                                                    
 BEGIN CATCH                         
                                                  
   DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();                                                    
   DECLARE @ErrorSeverity INT = ERROR_SEVERITY();                                                   
   DECLARE @ErrorState INT = ERROR_STATE();                                                       
   DECLARE @ErrorNumber INT = ERROR_NUMBER();                                                  
   DECLARE @ErrorLine INT = ERROR_LINE();                                                 
   DECLARE @ErrorProcedure NVARCHAR(1000) = ERROR_PROCEDURE();                                               
  
   EXEC uspExceptionLogInsert @ErrorLine,@ErrorMessage,@ErrorNumber,@ErrorProcedure,@ErrorSeverity,@ErrorState                                                  
            
 END CATCH   


End
