-- Author:   Chaitanya Kasar
-- Create date: 29/12/2023
-- Description:  This stored procedure is used Update Teacher profile
-- =============================================
CREATE PROC dbo.uspTeacherProfileUpdate(
  @TeacherId BIGINT, 
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
  @Education NVARCHAR (50), 
  @BloodGroup NVARCHAR (5), 
  @ProfileImageUrl NVARCHAR(250),
  @UserId INT
)
AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON DECLARE @CurrentDateTime DATETIME = GETDATE();
BEGIN TRY IF @TeacherId>0
BEGIN
UPDATE 
  Teacher 
  SET 
  [EmailId] = @EmailId, 
  [MobileNumber] = @MobileNumber,
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
  [ZipCode] = @ZipCode, 
  [Education] = @Education, 
  [BloodGroup] = @BloodGroup,
  [ProfileImageUrl]=@ProfileImageUrl,
  [ModifiedBy] = @UserId, 
  [ModifiedDate] = @CurrentDateTime
   WHERE 
  TeacherId = @TeacherId
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
GO
