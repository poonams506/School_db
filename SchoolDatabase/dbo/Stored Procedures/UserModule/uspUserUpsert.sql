-- =============================================
-- Author:    Deepak Walunj
-- Create date: 07/08/2023
-- Description:  This stored procedure is used insert user
-- =============================================
CREATE PROCEDURE uspUserUpsert (
  @IsLoginAccess BIT = 1,
  @AppAccessOldUserId INT= NULL,
  @IsDifferentUserRoleExist BIT = 0,
  @MobileNumber NVARCHAR(20) = NULL, 
  @Upassword VARCHAR(1000),
  @PasswordSalt VARCHAR(1000),
  @UserTypeId INT,
  @UserId INT,
  @FName NVARCHAR(200),
  @LName NVARCHAR(200),
  @RefId INT = NULL
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 

  NOCOUNT ON 
  DECLARE @CurrentDateTime DATETIME = GETDATE();
  DECLARE @InsertedUserId INT

BEGIN TRY 

IF @IsLoginAccess = 1
BEGIN
     

     SELECT TOP (1) @InsertedUserId=UserId FROM dbo.[User]
                  WHERE Uname = @MobileNumber AND IsDeleted <> 1
                  ORDER BY CreatedDate DESC;

     IF ISNULL(@InsertedUserId,0) = 0
     BEGIN
        -- Insert new user as no any user exist for same mobile number
         INSERT INTO dbo.[User]([MobileNumber], [Uname], [Upassword], 
                        [PasswordSalt],[CreatedBy], [CreatedDate],FName,LName) 
                     VALUES(@MobileNumber, @MobileNumber, @Upassword, 
                     @PasswordSalt,@UserId, @CurrentDateTime,@FName,@LName)
         
         SET @InsertedUserId = SCOPE_IDENTITY();

        -- Insert new userrole for newly created user
        INSERT INTO dbo.[UserRole](UserId, RoleId, RefId, 
                                    CreatedBy, CreatedDate)
                     VALUES(@InsertedUserId, @UserTypeId, @RefId, 
                              @UserId,  @CurrentDateTime);

        
     END
     ELSE
     BEGIN

        -- Update User
        IF EXISTS (SELECT UserId FROM dbo.[User] WHERE UserId=@InsertedUserId AND IsFirstTimeLogin = 1 AND IsDeleted <> 1)
        BEGIN
         UPDATE dbo.[User] SET [Uname]=@MobileNumber, [Upassword]=@Upassword, 
                        [PasswordSalt]=@PasswordSalt,[ModifiedBy]=@UserId, 
                        [ModifiedDate]=@CurrentDateTime
                    WHERE UserId=@InsertedUserId;
        END
        
        -- update fName & LName for user 
        IF @UserTypeId != 5
        BEGIN
             UPDATE dbo.[User] SET [Fname] = @FName, [Lname] = @LName, [ModifiedBy]=@UserId, 
                        [ModifiedDate]=@CurrentDateTime
                    WHERE UserId=@InsertedUserId;
        END

         -- Check if userrole exist for already existing user
         IF NOT EXISTS(SELECT 1 FROM dbo.[UserRole]
         WHERE UserId = @InsertedUserId AND RoleId = @UserTypeId
         AND IsDeleted <> 1)
         BEGIN
              -- Insert userrole for existing user
              INSERT INTO dbo.[UserRole](UserId, RoleId, RefId, 
                                         CreatedBy, CreatedDate)
                     VALUES(@InsertedUserId, @UserTypeId, @RefId, 
                                         @UserId,  @CurrentDateTime);
         END
     END
END

 IF  ISNULL(@IsDifferentUserRoleExist,0)<>1
 BEGIN
      DELETE FROM dbo.UserRole 
      WHERE UserId=@AppAccessOldUserId AND RoleId=@UserTypeId 
            AND IsDeleted <> 1;
 END
  

END TRY
BEGIN CATCH 

DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
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
