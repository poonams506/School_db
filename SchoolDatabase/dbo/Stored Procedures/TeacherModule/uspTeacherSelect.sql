-- =============================================
-- Author:    Swapnil Bhaskar
-- Create date: 07/08/2023
-- Description:  This stored procedure is used to get Teacher info detail by Id
-- =============================================
CREATE PROC dbo.uspTeacherSelect(@TeacherId BIGINT = NULL) AS Begin 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 
SELECT 
  TeacherId,
  FirstName, 
  MiddleName, 
  LastName, 
  CONCAT(FirstName,' ',MiddleName,' ',LastName) AS TeacherFullName,
  Gender, 
  ContactNumber, 
  MobileNumber, 
  EmailId, 
  AddressLine1, 
  AddressLine2, 
  TalukaId, 
  DistrictId, 
  StateId, 
  AdharNumber, 
  CountryId, 
  TalukaName, 
  DistrictName,
  StateName, 
  CountryName,
  ZipCode, 
  Education, 
  BirthDate, 
  BloodGroup, 
  ProfileImageUrl,
  IsAppAccess,
  AppAccessMobileNo,
  AppAccessOneTimePassword
FROM 
  dbo.Teacher 
WHERE 
  TeacherId = ISNULL(@TeacherId, TeacherId)
  AND IsDeleted <> 1
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
@ErrorState END CATCH End
GO
