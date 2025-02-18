-- =============================================
-- Author:    Swapnil Bhaskar
-- Create date: 05/08/2023
-- Description:  This stored procedure is used insert school profile
-- =============================================
CREATE PROCEDURE uspSchoolUpsert (
  @SchoolId SMALLINT, 
  @SchoolName NVARCHAR(500), 
  @SchoolCode NVARCHAR(15), 
  @SchoolCodeNo NVARCHAR(100), 
  @SchoolEmail VARCHAR(80), 
  @SchoolContactNo1 NVARCHAR(20), 
  @SchoolContactNo2 NVARCHAR(20), 
  @SchoolAddressLine1 NVARCHAR(250), 
  @SchoolAddressLine2 NVARCHAR(250), 
  @TalukaId INT, 
  @DistrictId INT, 
  @StateId INT, 
  @CountryId INT, 
  @TalukaName NVARCHAR(100), 
  @DistrictName NVARCHAR(100), 
  @StateName NVARCHAR(100), 
  @CountryName NVARCHAR(100),
  @Pincode NVARCHAR(10), 
  @EstablishmentDate DATE, 
  @SchoolRank NVARCHAR(250), 
  @SchoolWebsiteUrl NVARCHAR(250), 
  @LogoUrl VARCHAR(100), 
  @BannerUrl VARCHAR(100), 
  @SchoolDescription NVARCHAR(500), 
  @ContactPersonName NVARCHAR(50), 
  @ContactPersonRole NVARCHAR(50), 
  @ContactPersonEmail VARCHAR(80), 
  @ContactPersonMobileNo NVARCHAR(20), 
  @AcademicYearId SMALLINT, 
  @AuthorisedBy NVARCHAR(500), 
  @Section NVARCHAR(500), 
  @SchoolMediumId SMALLINT, 
  @SchoolPermission NVARCHAR(500), 
  @RegistrationNumber NVARCHAR(500), 
  @SchoolType NVARCHAR(200), 
  @UdiseNumber NVARCHAR(500), 
  @Board NVARCHAR(500), 
  @AffiliationNumber NVARCHAR(500), 
  @HscOrSscIndexNo NVARCHAR(200), 
  @UserId INT
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON DECLARE @CurrentDateTime DATETIME = GETDATE();
BEGIN TRY 
IF EXISTS (SELECT SchoolId FROM School)
BEGIN --Update Statement
UPDATE 
  School 
SET 
  [SchoolName] = @SchoolName, 
  [SchoolCode] = @SchoolCode, 
  [SchoolCodeNo] = @SchoolCodeNo, 
  [SchoolEmail] = @SchoolEmail, 
  [SchoolContactNo1] = @SchoolContactNo1, 
  [SchoolContactNo2] = @SchoolContactNo2, 
  [SchoolAddressLine1] = @SchoolAddressLine1, 
  [SchoolAddressLine2] = @SchoolAddressLine2, 
  [TalukaId] = @TalukaId, 
  [DistrictId] = @DistrictId, 
  [StateId] = @StateId, 
  [CountryId] = @CountryId, 
  [TalukaName] = @TalukaName,
  [DistrictName] = @DistrictName,
  [StateName] = @StateName,
  [CountryName] = @CountryName,
  [Pincode] = @Pincode, 
  [EstablishmentDate] = @EstablishmentDate, 
  [SchoolRank] = @SchoolRank, 
  [SchoolWebsiteUrl] = @SchoolWebsiteUrl, 
  [LogoUrl] = @LogoUrl, 
  [BannerUrl] = @BannerUrl, 
  [SchoolDescription] = @SchoolDescription, 
  [ContactPersonName] = @ContactPersonName, 
  [ContactPersonRole] = @ContactPersonRole, 
  [ContactPersonEmail] = @ContactPersonEmail, 
  [ContactPersonMobileNo] = @ContactPersonMobileNo, 
  [AcademicYearId] = @AcademicYearId, 
  [AuthorisedBy] = @AuthorisedBy, 
  [Section] = @Section, 
  [SchoolMediumId] = @SchoolMediumId, 
  [SchoolPermission] = @SchoolPermission, 
  [RegistrationNumber] = @RegistrationNumber, 
  [SchoolType] = @SchoolType, 
  [UdiseNumber] = @UdiseNumber, 
  [Board] = @Board, 
  [AffiliationNumber] = @AffiliationNumber, 
  [HscOrSscIndexNo] = @HscOrSscIndexNo, 
  [ModifiedBy] = @UserId, 
  [ModifiedDate] = @CurrentDateTime 
--WHERE 
 -- [SchoolId] = @SchoolId
  END
  ELSE 
  BEGIN --INSERT Statement
  INSERT INTO School(
    [SchoolName], [SchoolCode], [SchoolCodeNo], [SchoolEmail], 
    [SchoolContactNo1], [SchoolContactNo2], 
    [SchoolAddressLine1], [SchoolAddressLine2], 
    [TalukaId], [DistrictId], [StateId], [CountryId], 
    [TalukaName], [DistrictName], [StateName], [CountryName],
    [Pincode], [EstablishmentDate], 
    [SchoolRank], [SchoolWebsiteUrl], 
    [LogoUrl], [BannerUrl], [SchoolDescription], 
    [ContactPersonName], [ContactPersonRole], 
    [ContactPersonEmail], [ContactPersonMobileNo], 
    [AcademicYearId], [AuthorisedBy], 
    [Section], [SchoolMediumId], [SchoolPermission], 
    [RegistrationNumber], [SchoolType], 
    [UdiseNumber], [Board], [AffiliationNumber], 
    [HscOrSscIndexNo], [CreatedBy], 
    [CreatedDate]
  ) 
VALUES 
  (
    @SchoolName, @SchoolCode, @SchoolCodeNo, @SchoolEmail, 
    @SchoolContactNo1, @SchoolContactNo2, 
    @SchoolAddressLine1, @SchoolAddressLine2, 
    @TalukaId, @DistrictId, @StateId, @CountryId, 
    @TalukaName, @DistrictName, @StateName, @CountryName,
    @Pincode, @EstablishmentDate, 
    @SchoolRank, @SchoolWebsiteUrl, 
    @LogoUrl, @BannerUrl, @SchoolDescription, 
    @ContactPersonName, @ContactPersonRole, 
    @ContactPersonEmail, @ContactPersonMobileNo, 
    @AcademicYearId, @AuthorisedBy, 
    @Section, @SchoolMediumId, @SchoolPermission, 
    @RegistrationNumber, @SchoolType, 
    @UdiseNumber, @Board, @AffiliationNumber, 
    @HscOrSscIndexNo, @UserId, @CurrentDateTime
  ) 
  
  SET @SchoolId = (SELECT SchoolId FROM School);

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
@ErrorState 
END CATCH

SELECT @SchoolId;

END
