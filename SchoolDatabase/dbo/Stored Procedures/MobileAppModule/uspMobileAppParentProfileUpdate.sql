-- =============================================
-- Author:   Abhishek Kumar
-- Create date: 18/04/2024
-- Description:  This stored procedure is used to update parent profile
-- =============================================
CREATE PROCEDURE uspMobileAppParentProfileUpdate(
  @StudentId BIGINT,
  @ParentId INT,
  @ParentTypeId INT,
  @FirstName NVARCHAR(50),
  @MiddleName NVARCHAR(50),
  @LastName NVARCHAR(50),
  @AddressLine1 NVARCHAR (250),
  @AddressLine2 NVARCHAR (250), 
  @TalukaId INT, 
  @DistrictId INT, 
  @StateId INT, 
  @CountryId INT,
  @Zipcode NVARCHAR(10),
  @ProfileImageURL VARCHAR(100), 
  @UserId INT)
  AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET  NOCOUNT ON 

DECLARE @CurrentDateTime DATETIME = GETDATE();
BEGIN TRY

DECLARE @InsertedId TABLE(Id INT NOT NULL);

MERGE INTO dbo.Parent AS Target
USING (SELECT @StudentId,@ParentId,@ParentTypeId,@FirstName, @MiddleName, 
      @LastName,@AddressLine1,@AddressLine2, @TalukaId,@DistrictId,@StateId,
	  @CountryId,@Zipcode,@ProfileImageURL,@UserId,@CurrentDateTime)
	  Source(StudentId,ParentId,ParentTypeId,FirstName, MiddleName, 
      LastName,AddressLine1,AddressLine2, TalukaId,DistrictId,StateId,
	  CountryId,Zipcode,ProfileImageURL,UserId,CurrentDateTime)
  ON Source.ParentId=Target.ParentId AND Source.ParentId>0
  WHEN MATCHED THEN UPDATE SET 
					Target.FirstName=Source.FirstName,
					Target.MiddleName=Source.MiddleName,
					Target.LastName=Source.LastName,
					Target.AddressLine1=Source.AddressLine1,
					Target.AddressLine2=Source.AddressLine2,
                    Target.CountryId=Source.CountryId,
                    Target.StateId=Source.StateId,
					Target.DistrictId=Source.DistrictId,
                    Target.TalukaId=Source.TalukaId,
                    Target.Zipcode=Source.Zipcode,
					Target.ProfileImageURL=Source.ProfileImageURL,
					Target.ModifiedBy=Source.UserId,
					Target.ModifiedDate=Source.CurrentDateTime
	WHEN NOT MATCHED THEN
				INSERT(ParentTypeId,FirstName,MiddleName,LastName,AddressLine1,
				AddressLine2,CountryId,StateId,DistrictId,TalukaId,
				Zipcode,ProfileImageURL,CreatedBy,CreatedDate)
				VALUES(Source.ParentTypeId,Source.FirstName,Source.MiddleName,Source.LastName,
				Source.AddressLine1,Source.AddressLine2,Source.CountryId,Source.StateId,Source.DistrictId,
				Source.TalukaId,Source.Zipcode,Source.ProfileImageURL,Source.UserId,Source.CurrentDateTime)
	OUTPUT Inserted.ParentId INTO @InsertedId;

	IF @ParentId=0
	BEGIN
		INSERT INTO dbo.ParentStudentMapping(ParentId, StudentId)
		SELECT Id,@StudentId FROM @InsertedId;
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
