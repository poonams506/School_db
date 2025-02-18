-- =============================================
-- Author:    Deepak Walunj
-- Create date: 05/08/2023
-- Description:  This stored procedure is used to get school info detail by Id
-- =============================================
CREATE PROC uspSchoolSelect(@SchoolId SMALLINT = NULL) AS Begin 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 
SELECT 
  SchoolId,
  SchoolName, 
  SchoolCode, 
  SchoolCodeNo,
  SchoolEmail, 
  SchoolContactNo1, 
  SchoolContactNo2, 
  SchoolAddressLine1, 
  SchoolAddressLine2, 
  TalukaId, 
  DistrictId, 
  StateId, 
  CountryId,
  TalukaName, 
  DistrictName,
  StateName, 
  CountryName,
  Pincode, 
  EstablishmentDate, 
  SchoolRank, 
  SchoolWebsiteUrl, 
  LogoUrl, 
  BannerUrl, 
  SchoolDescription, 
  ContactPersonName, 
  ContactPersonRole, 
  ContactPersonEmail, 
  ContactPersonMobileNo, 
  AcademicYearId, 
  AuthorisedBy, 
  Section, 
  SchoolMediumId, 
  SchoolPermission, 
  RegistrationNumber, 
  SchoolType, 
  UdiseNumber, 
  Board, 
  AffiliationNumber, 
  HscOrSscIndexNo,
  ISNULL(SchoolAddressLine1,'') + IIF(SchoolAddressLine1 IS NULL,'',', ') + ISNULL(SchoolAddressLine2,'') + IIF(SchoolAddressLine2 IS NULL,'',', ') + TalukaName + ', ' + DistrictName + ', ' + StateName + ', ' + Pincode AS SchoolAddress
  ,mt.MediumTypeName
FROM 
  School s
  INNER JOIN MediumType mt ON mt.MediumTypeId = s.SchoolMediumId
WHERE SchoolId = ISNULL(@SchoolId, SchoolId) AND s.IsDeleted <> 1
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
End
