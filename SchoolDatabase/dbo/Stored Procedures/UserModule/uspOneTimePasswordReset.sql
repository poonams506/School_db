CREATE PROCEDURE uspOneTimePasswordReset (
  @PasswordSalt NVARCHAR(250)
, @UserName NVARCHAR(250)
, @Upassword NVARCHAR(250)
)
AS

BEGIN

  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
  SET NOCOUNT ON
  BEGIN TRY 
    DECLARE @CurrentDateTime DATETIME= GETDATE();
    --update user password
    UPDATE [User] SET Upassword=@Upassword, PasswordSalt = @PasswordSalt, IsFirstTimeLogin = 1 WHERE Uname=@UserName;

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