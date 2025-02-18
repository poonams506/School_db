-- =============================================
-- Author:    Deepak Walunj
-- Create date: 16/08/2023
-- Description:  This stored procedure is used insert Admin profile
-- =============================================
CREATE PROCEDURE uspAdminUpsert (
  @AdminId BIGINT,
  @FirstName NVARCHAR(50), 
  @MiddleName NVARCHAR (50), 
  @LastName NVARCHAR (50), 
  @Gender NVARCHAR (5), 
  @ContactNumber NVARCHAR(20), 
  @MobileNumber NVARCHAR(20), 
  @EmailId VARCHAR(80), 
  @AddressLine1 NVARCHAR(250), 
  @AddressLine2 NVARCHAR (250), 
  @TalukaId INT, 
  @DistrictId INT, 
  @StateId INT, 
  @CountryId INT,
  @TalukaName NVARCHAR(100), 
  @DistrictName NVARCHAR(100), 
  @StateName NVARCHAR(100), 
  @CountryName NVARCHAR(100),
  @ZipCode NVARCHAR (10), 
  @AdharNumber NVARCHAR (20), 
  @Education NVARCHAR (50), 
  @BirthDate DATE, 
  @BloodGroup NVARCHAR (5), 
  @ProfileImageUrl VARCHAR(100), 
  @UserId INT,
  @IsAppAccess BIT = 0,
  @Upassword VARCHAR(1000)=NULL,
  @PasswordSalt VARCHAR(1000)=NULL,
  @AppAccessMobileNo VARCHAR(20) = NULL,
  @AppAccessOneTimePassword NVARCHAR(100) = NULL
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON DECLARE @CurrentDateTime DATETIME = GETDATE();
  DECLARE @AppAccessOldMobileNo VARCHAR(20),@AppAccessOldUserId INT, @IsDifferentUserRoleExist BIT;
BEGIN TRY IF @AdminId > 0 BEGIN --Update Statement
SET @AppAccessOldMobileNo=(SELECT TOP 1 AppAccessMobileNo FROM Admin WHERE AdminId=@AdminId);
UPDATE 
  [Admin] 
SET
  [FirstName] = @FirstName, 
  [MiddleName] = @MiddleName, 
  [LastName] = @LastName, 
  [Gender] = @Gender, 
  [ContactNumber] = @ContactNumber, 
  [MobileNumber] = @MobileNumber, 
  [EmailId] = @EmailId, 
  [AddressLine1] = @AddressLine1, 
  [AddressLine2] = @AddressLine2, 
  [TalukaId] = @TalukaId, 
  [DistrictId] = @DistrictId, 
  [StateId] = @StateId, 
  [AdharNumber] = @AdharNumber, 
  [CountryId] = @CountryId, 
  [TalukaName] = @TalukaName,
  [DistrictName] = @DistrictName,
  [StateName] = @StateName,
  [CountryName] = @CountryName,
  [ZipCode] = @ZipCode, 
  [Education] = @Education, 
  [BirthDate] = @BirthDate, 
  [BloodGroup] = @BloodGroup, 
  [ProfileImageUrl] = @ProfileImageUrl, 
  [ModifiedBy] = @UserId, 
  [ModifiedDate] = @CurrentDateTime,
  [IsAppAccess] = @IsAppAccess,
  [AppAccessMobileNo] = @AppAccessMobileNo,
  [AppAccessOneTimePassword] = @AppAccessOneTimePassword
WHERE 
  [AdminId] = @AdminId END ELSE BEGIN --INSERT Statement
  INSERT INTO [Admin](
    [FirstName], [MiddleName], 
    [LastName], [Gender], [ContactNumber], 
    [MobileNumber], [EmailId], [AddressLine1], 
    [AddressLine2], [TalukaId], [DistrictId], 
    [StateId], [AdharNumber], [CountryId], 
    [TalukaName], [DistrictName], [StateName], [CountryName],
    [ZipCode], [Education], [BirthDate], 
    [BloodGroup], [ProfileImageUrl], 
    [CreatedBy], [CreatedDate],
    [IsAppAccess], [AppAccessMobileNo], [AppAccessOneTimePassword]
  ) 
VALUES 
  (
    @FirstName, @MiddleName, 
    @LastName, @Gender, @ContactNumber, 
    @MobileNumber, @EmailId, @AddressLine1, 
    @AddressLine2, @TalukaId, @DistrictId, 
    @StateId, @AdharNumber, @CountryId, 
    @TalukaName, @DistrictName, @StateName, @CountryName,
    @ZipCode, @Education, @BirthDate, 
    @BloodGroup, @ProfileImageUrl, @UserId, 
    @CurrentDateTime,
    @IsAppAccess, @AppAccessMobileNo, @AppAccessOneTimePassword
  ) 
  SET @AdminId = SCOPE_IDENTITY();
  SET @AppAccessOldMobileNo=@AppAccessMobileNo;
  END 
  SET @AppAccessOldUserId=(SELECT TOP 1 UserId FROM [User] WHERE MobileNumber=@AppAccessOldMobileNo AND Uname=@AppAccessOldMobileNo);
  IF  EXISTS(SELECT 1 FROM Admin WHERE AppAccessMobileNo=@AppAccessOldMobileNo)
  BEGIN
    SET @IsDifferentUserRoleExist=1;
  END
  EXEC uspUserUpsert @IsAppAccess,@AppAccessOldUserId,@IsDifferentUserRoleExist,@AppAccessMobileNo,@Upassword,@PasswordSalt,2,@UserId,@FirstName,@LastName,@AdminId 

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
