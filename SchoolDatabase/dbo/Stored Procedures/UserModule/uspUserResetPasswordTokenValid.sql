-- =============================================
-- Author:		Abhishek Kumar
-- Create date: 18/04/2023
-- Description:	This stored procedure is used to check if user reset password token is valid
-- =============================================
CREATE PROC uspUserResetPasswordTokenValid(@Token NVARCHAR(250),@CurrentDate NVARCHAR(250))
AS
Begin
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;                              
	SET NOCOUNT ON;  

	BEGIN TRY 

		SELECT TOP 1 usr.UserId FROM [User] usr 
        JOIN UserResetPassword usrp ON usr.UserId=usrp.UserId
		WHERE Token=@Token AND usrp.ExpirationDate>@CurrentDate AND usr.IsDeleted<>1 AND usrp.IsDeleted<>1;

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

