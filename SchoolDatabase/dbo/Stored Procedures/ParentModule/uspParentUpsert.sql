-- =============================================
-- Author:    Swapnil Bhaskar
-- Create date: 07/08/2023
-- Description:  This stored procedure is used insert Parent profile
-- =============================================
-- Modified By :  Deepak Walunj
-- Desc : Added user creation process
CREATE PROCEDURE uspParentUpsert (
  @ParentId BIGINT, 
  @ParentTypeId SMALLINT, 
  @FirstName NVARCHAR(50), 
  @MiddleName NVARCHAR(50), 
  @LastName NVARCHAR(50), 
  @Gender NVARCHAR(5), 
  @ContactNumber NVARCHAR(20), 
  @MobileNumber NVARCHAR(20), 
  @EmailId VARCHAR(80), 
  @AddressLine1 NVARCHAR(250), 
  @AddressLine2 NVARCHAR(250), 
  @TalukaId INT, 
  @DistrictId INT, 
  @StateId INT, 
  @CountryId INT, 
  @TalukaName NVARCHAR(100), 
  @DistrictName NVARCHAR(100), 
  @StateName NVARCHAR(100), 
  @CountryName NVARCHAR(100), 
  @Zipcode NVARCHAR(10), 
  @AdharNumber NVARCHAR(20), 
  @Education NVARCHAR(50), 
  @BirthDate DATE, 
  @Occupation NVARCHAR(50), 
  @AnnualIncome MONEY, 
  @BloodGroup NVARCHAR(5), 
  @ProfileImageURL VARCHAR(100), 
  @UserId INT,
  @StudentId BIGINT
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 
  /*
  UserTypeId = 1 ==> SuperAdmin
  UserTypeId =  2 ==> Admin
  UserTypeId = 3 ==> Teacher
  UserTypeId = 4 ==> Cleark
  UserTypeId = 5 ==> CabDriver
  ParentTypeId/UserTypeId = 11 ==> Father
  ParentTypeId/UserTypeId = 12 ==> Mother
  ParentTypeId/UserTypeId = 13 ==> Guardian
  */
  DECLARE @CurrentDateTime DATETIME = GETDATE();
  BEGIN TRY IF @ParentId > 0 BEGIN --Update Statement
       UPDATE 
       Parent 
       SET 
         [ParentTypeId] = @ParentTypeId, 
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
         [CountryId] = @CountryId, 
         [TalukaName] = @TalukaName,
         [DistrictName] = @DistrictName,
         [StateName] = @StateName,
         [CountryName] = @CountryName,
         [Zipcode] = @Zipcode, 
         [AdharNumber] = @AdharNumber, 
         [Education] = @Education, 
         [BirthDate] = @BirthDate, 
         [Occupation] = @Occupation, 
         [AnnualIncome] = @AnnualIncome, 
         [BloodGroup] = @BloodGroup, 
         [ProfileImageURL] = @ProfileImageURL, 
         [ModifiedBy] = @UserId, 
         [ModifiedDate] = @CurrentDateTime
       WHERE 
         [ParentId] = @ParentId
  END 
  ELSE 
  BEGIN --INSERT Statement
  
       INSERT INTO Parent(
       [ParentTypeId], [FirstName], [MiddleName], 
       [LastName], [Gender], [ContactNumber], 
       [MobileNumber], [EmailId], [AddressLine1], 
       [AddressLine2], 
       [TalukaId], [DistrictId], [StateId], [CountryId],
       [TalukaName], [DistrictName], [StateName], [CountryName],
       [Zipcode], 
       [AdharNumber], [Education], [BirthDate], 
       [Occupation], [AnnualIncome], [BloodGroup], 
       [ProfileImageURL], [CreatedBy], 
       [CreatedDate]
       ) 
        VALUES 
       (
       @ParentTypeId, @FirstName, @MiddleName, 
       @LastName, @Gender, @ContactNumber, 
       @MobileNumber, @EmailId, @AddressLine1, 
       @AddressLine2,
       @TalukaId, @DistrictId, @StateId, @CountryId,
       @TalukaName, @DistrictName, @StateName, @CountryName,
       @Zipcode, @AdharNumber, 
       @Education, @BirthDate, @Occupation, 
       @AnnualIncome, @BloodGroup, @ProfileImageURL, 
       @UserId, @CurrentDateTime
       )
       SET @ParentId = SCOPE_IDENTITY();
       INSERT INTO ParentStudentMapping(ParentId,StudentId) 
       VALUES(@ParentId,@StudentId);
END   
  SELECT @ParentId
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
