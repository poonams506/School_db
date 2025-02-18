-- =============================================
-- Author:		Abhishek Kumar
-- Create date: 27/03/2023
-- Description:	This stored procedure is used to check if user is valid by username and hashpassword
-- =============================================
CREATE PROC uspUserValid(@Username NVARCHAR(250),@Hashedpassword NVARCHAR(MAX), @UnHashedpassword NVARCHAR(50), @AllOneTimePassword NVARCHAR(MAX) = NULL)
AS
Begin
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;                              
	SET NOCOUNT ON;  

	BEGIN TRY 
	    DECLARE @UserId INT;
		DECLARE @IsFirstTimeLogin BIT;
		SET @UserId = (SELECT TOP (1) UserId FROM dbo.[User] WHERE Uname=@Username AND Upassword=@Hashedpassword AND IsDeleted<>1 ORDER BY UserId DESC);
		SET @IsFirstTimeLogin = (SELECT TOP (1) IsFirstTimeLogin FROM dbo.[User] WHERE Uname=@Username AND IsFirstTimeLogin = 1 AND IsDeleted <> 1 ORDER BY UserId DESC)
		IF (@UserId IS NULL OR @UserId = 0) AND @IsFirstTimeLogin = 1
		BEGIN
		    DECLARE @StudentId INT;
		    SET @StudentId = (SELECT TOP (1) StudentId FROM dbo.Student WHERE IsDeleted <> 1 AND IsArchive <> 1 AND AppAccessMobileNo = @Username AND AppAccessOneTimePassword = @UnHashedpassword ORDER BY StudentId DESC)
			IF @StudentId > 0
			BEGIN
			    SET @UserId = (SELECT TOP (1) UserId FROM dbo.[User] WHERE Uname=@Username AND IsDeleted<>1  ORDER BY UserId DESC);
			END
		END
		IF (@UserId IS NULL OR @UserId = 0) AND @IsFirstTimeLogin = 1
		BEGIN
		    DECLARE @TeacherId INT;
		    SET @TeacherId = (SELECT TOP (1) TeacherId FROM dbo.Teacher WHERE IsDeleted <> 1 AND AppAccessMobileNo = @Username AND AppAccessOneTimePassword = @UnHashedpassword ORDER BY TeacherId DESC)
			IF @TeacherId > 0
			BEGIN
			    SET @UserId = (SELECT TOP (1) UserId FROM dbo.[User] WHERE Uname=@Username AND IsDeleted<>1  ORDER BY UserId DESC);
			END
		END
		IF (@UserId IS NULL OR @UserId = 0) AND @IsFirstTimeLogin = 1
		BEGIN
		    DECLARE @ClerkId INT;
		    SET @ClerkId = (SELECT TOP (1) ClerkId FROM dbo.Clerk WHERE IsDeleted <> 1 AND AppAccessMobileNo = @Username AND AppAccessOneTimePassword = @UnHashedpassword ORDER BY ClerkId DESC)
			IF @ClerkId > 0
			BEGIN
			    SET @UserId = (SELECT TOP (1) UserId FROM dbo.[User] WHERE Uname=@Username AND IsDeleted<>1  ORDER BY UserId DESC);
			END
		END
		IF (@UserId IS NULL OR @UserId = 0) AND @IsFirstTimeLogin = 1
		BEGIN
		    DECLARE @AdminId INT;
		    SET @AdminId = (SELECT TOP (1) AdminId FROM dbo.[Admin] WHERE IsDeleted <> 1 AND AppAccessMobileNo = @Username AND AppAccessOneTimePassword = @UnHashedpassword ORDER BY AdminId DESC)
			IF @AdminId > 0
			BEGIN
			    SET @UserId = (SELECT TOP (1) UserId FROM dbo.[User] WHERE Uname=@Username AND IsDeleted<>1  ORDER BY UserId DESC);
			END
		END
		IF (@UserId IS NULL OR @UserId = 0) AND @IsFirstTimeLogin = 1
		BEGIN
		    DECLARE @CabDriverId INT;
		    SET @CabDriverId = (SELECT TOP (1) CabDriverId FROM dbo.[CabDriver] WHERE IsDeleted <> 1 AND AppAccessMobileNo = @Username AND AppAccessOneTimePassword = @UnHashedpassword ORDER BY CabDriverId DESC)
			IF @CabDriverId > 0
			BEGIN
			    SET @UserId = (SELECT TOP (1) UserId FROM dbo.[User] WHERE Uname=@Username AND IsDeleted<>1 ORDER BY UserId DESC);
			END
		END
		IF(@UserId IS NULL)
		BEGIN
			SELECT 0;
		END
		ELSE
		BEGIN
			SELECT @UserId;
		END
	
		
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

