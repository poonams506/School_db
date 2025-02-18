CREATE PROC uspAllOneTimePasswordSelect(@UserName NVARCHAR(100))
AS
Begin
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;                              
	SET NOCOUNT ON;  

	BEGIN TRY 
	   

		    SELECT Top 1 AppAccessOneTimePassword FROM Admin WHERE AppAccessMobileNo = @UserName AND IsDeleted <> 1 
			UNION ALL
		    SELECT Top 1 AppAccessOneTimePassword FROM Teacher WHERE AppAccessMobileNo = @UserName AND IsDeleted <> 1 
			UNION ALL
		    SELECT Top 1 AppAccessOneTimePassword FROM Clerk WHERE AppAccessMobileNo = @UserName AND IsDeleted <> 1 
			UNION ALL
		    SELECT Top 1 AppAccessOneTimePassword FROM Student WHERE AppAccessMobileNo = @UserName AND IsDeleted <> 1  AND IsArchive <> 1
			UNION ALL
		    SELECT Top 1 AppAccessOneTimePassword FROM CabDriver WHERE AppAccessMobileNo = @UserName AND IsDeleted <> 1 



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

