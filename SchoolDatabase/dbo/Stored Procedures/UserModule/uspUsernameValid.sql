-- =============================================
-- Author:		Abhishek Kumar
-- Create date: 27/03/2023
-- Description:	This stored procedure is used to check if username is valid by username and hashpassword
-- =============================================
CREATE PROC uspUsernameValid(@Username NVARCHAR(250))
AS
Begin
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;                              
	SET NOCOUNT ON;  

	BEGIN TRY 

		SELECT TOP 1 UserId FROM [User] WHERE Uname=@Username AND IsDeleted<>1;

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

