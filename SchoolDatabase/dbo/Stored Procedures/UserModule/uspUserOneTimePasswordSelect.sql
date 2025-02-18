CREATE PROC uspUserOneTimePasswordSelect(@UserName NVARCHAR(100), @RoleId INT)
AS
Begin
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;                              
	SET NOCOUNT ON;  

	BEGIN TRY 
	   
	    --IF @RoleId = 1 -- Super Admin
		--BEGIN
		--    SELECT Top 1 AppAccessOneTimePassword FROM Student WHERE AppAccessMobileNo = @UserName AND IsDeleted <> 1 
		--END

		IF @RoleId = 2 -- Admin
		BEGIN
		    SELECT Top 1 AppAccessOneTimePassword FROM Admin WHERE AppAccessMobileNo = @UserName AND IsDeleted <> 1 
		END

		IF @RoleId = 3 -- Teacher
		BEGIN
		    SELECT Top 1 AppAccessOneTimePassword FROM Teacher WHERE AppAccessMobileNo = @UserName AND IsDeleted <> 1 
		END

		IF @RoleId = 4 -- Clerk
		BEGIN
		    SELECT Top 1 AppAccessOneTimePassword FROM Clerk WHERE AppAccessMobileNo = @UserName AND IsDeleted <> 1 
		END

		IF @RoleId = 5 -- Parent
		BEGIN
		    SELECT Top 1 AppAccessOneTimePassword FROM Student WHERE AppAccessMobileNo = @UserName AND IsDeleted <> 1  AND IsArchive <> 1
		END

		IF @RoleId = 6 -- Cab Driver
		BEGIN
		    SELECT Top 1 AppAccessOneTimePassword FROM CabDriver WHERE AppAccessMobileNo = @UserName AND IsDeleted <> 1 
		END

		--IF @RoleId = 7 --Principal
		--BEGIN
		--    SELECT Top 1 AppAccessOneTimePassword FROM Admin WHERE AppAccessMobileNo = @UserName AND IsDeleted <> 1 
		--END


		

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

