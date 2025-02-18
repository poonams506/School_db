-- =============================================
-- Author:   Chaitanya Kasar
-- Create date: 28/12/2023
-- Description:  This stored procedure is used Update student profile
-- =============================================
CREATE PROCEDURE uspStudentProfileUpdate(
  @StudentId BIGINT,
  @FirstName NVARCHAR(50),
  @MiddleName NVARCHAR(50),
  @LastName NVARCHAR(50),
  @CurrentAddressLine1 NVARCHAR (250),
  @CurrentAddressLine2 NVARCHAR (250), 
  @CurrentTalukaId INT, 
  @CurrentDistrictId INT, 
  @CurrentStateId INT, 
  @CurrentCountryId INT,
  @CurrentZipcode NVARCHAR(10),
  @ProfileImageURL VARCHAR(100), 
  @UserId INT)
  AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON DECLARE @CurrentDateTime DATETIME = GETDATE();
BEGIN TRY IF @StudentId>0
BEGIN
 UPDATE 
  dbo.Student 
  SET 
  [FirstName]= @FirstName,
  [MiddleName]= @MiddleName,
  [LastName] = @LastName,
  [CurrentAddressLine1] =@CurrentAddressLine1,
  [CurrentAddressLine2]=@CurrentAddressLine2, 
  [CurrentTalukaId]=@CurrentTalukaId, 
  [CurrentCountryId]=@CurrentCountryId, 
  [CurrentDistrictId]=@CurrentDistrictId, 
  [CurrentStateId]=@CurrentStateId, 
  [CurrentZipcode]=@CurrentZipcode,
  [ProfileImageURL]=@ProfileImageURL,
  [ModifiedBy] = @UserId, 
  [ModifiedDate] = @CurrentDateTime
  WHERE 
  StudentId = @StudentId
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
