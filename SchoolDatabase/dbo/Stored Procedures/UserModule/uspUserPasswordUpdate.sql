-- =============================================
-- Author:		Abhishek Kumar
-- Create date: 14/04/2023
-- Description:	This stored procedure is used to update password into user table and delete record from UserResetPassword
-- =============================================
CREATE PROCEDURE uspUserPasswordUpdate (
  @UserId INT
, @Password NVARCHAR(250)
, @Token NVARCHAR(250))
AS

BEGIN

  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
  SET NOCOUNT ON
  BEGIN TRY 
    DECLARE @CurrentDateTime DATETIME= GETDATE();
    --update user password
    UPDATE [User] SET Upassword=@Password,ModifiedBy=@UserId,ModifiedDate=@CurrentDateTime, IsFirstTimeLogin = 0 WHERE UserId=@UserId;

    --update is_deleted=1 in userresetpassword
    UPDATE [UserResetPassword] 
    SET IsDeleted=1,
    ModifiedBy=@UserId,ModifiedDate=@CurrentDateTime
    WHERE Token=@Token;
  
    SELECT 1;

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
END