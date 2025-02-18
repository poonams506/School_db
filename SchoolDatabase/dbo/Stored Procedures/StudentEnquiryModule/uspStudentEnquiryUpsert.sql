--===============================================
-- Author:- Gulave Pramod
-- Create date:- 06-08-2024:-
-- Description:- This stored procedure is used to get StudentEnquiryForm by Upsert. 
-- =============================================
CREATE PROCEDURE [dbo].[uspStudentEnquiryUpsert](
	@StudentEnquiryId INT,
	@EnquiryDate DATE,
	@StudentFirstName NVARCHAR(50),
	@StudentMiddleName NVARCHAR(50),
	@StudentLastName NVARCHAR(50),
	@Gender NVARCHAR(5),
	@BirthDate DATE,
	@AdharNo NVARCHAR(20),
	@Religion NVARCHAR(50),
	@Cast NVARCHAR(50),
	@Category NVARCHAR(50),
	@Nationality NVARCHAR(50),
	@MobileNumber NVARCHAR(20),
	@InterestedClassId INT,
	@AcademicYearId SMALLINT,
	@CurrentSchool NVARCHAR(250),
	@CurrentClass NVARCHAR(20),
	@NameOfSiblingInCurrentSchool NVARCHAR(50),
	@FatherFirstName NVARCHAR(50),
	@FatherMiddleName NVARCHAR(50),
	@FatherLastName NVARCHAR(50),
	@MotherFirstName NVARCHAR(50),
	@MotherMiddleName NVARCHAR(50),
	@MotherLastName NVARCHAR(50),
	@AddressLine1 NVARCHAR(250),
	@AddressLine2 NVARCHAR(250),
	@CountryId INT,
	@CountryName NVARCHAR(100),
	@StateId INT,
	@StateName NVARCHAR(100),
	@TalukaId INT,
	@TalukaName NVARCHAR(100),
	@DistrictId INT,
	@DistrictName NVARCHAR(100),
	@EmailId VARCHAR(80),
	@ReferenceBy NVARCHAR(50),
	@EnquiryTypeId SMALLINT,
	@EnquiryStatusId INT,
	@UserId INT
)
AS 
BEGIN 
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;
    DECLARE @CurrentDateTime DATETIME = GETDATE();
    BEGIN TRY 
        IF @StudentEnquiryId > 0 
        BEGIN 
            UPDATE dbo.StudentEnquiry
            SET
				[EnquiryDate]=@EnquiryDate,
				[StudentFirstName] = @StudentFirstName,
				[StudentMiddleName] = @StudentMiddleName,
				[StudentLastName] = @StudentLastName,
				[Gender] = @Gender,
				[BirthDate] = @BirthDate,
				[AdharNo] = @AdharNo,
				[Religion] = @Religion,
				[Cast] = @Cast,
				[Category] = @Category,
				[Nationality] = @Nationality,
				[MobileNumber] = @MobileNumber,
				[InterestedClassId] = @InterestedClassId,
				[AcademicYearId] = @AcademicYearId,
				[CurrentSchool] = @CurrentSchool,
				[CurrentClass] = @CurrentClass,
				[NameOfSiblingInCurrentSchool] = @NameOfSiblingInCurrentSchool,
				[FatherFirstName] = @FatherFirstName,
				[FatherMiddleName] = @FatherMiddleName,
				[FatherLastName] = @FatherLastName,
				[MotherFirstName] = @MotherFirstName,
				[MotherMiddleName] = @MotherMiddleName,
				[MotherLastName] = @MotherLastName,
				[AddressLine1] = @AddressLine1,
				[AddressLine2] = @AddressLine2,
				[CountryId] = @CountryId,
				[CountryName] = @CountryName,
				[StateId] = @StateId,
				[StateName] = @StateName,
				[TalukaId] = @TalukaId,
				[TalukaName] = @TalukaName,
				[DistrictId] = @DistrictId,
				[DistrictName] = @DistrictName,
				[EmailId]=@EmailId,
				[ReferenceBy]=@ReferenceBy,
				[EnquiryTypeId]=@EnquiryTypeId,
				[EnquiryStatusId]=@EnquiryStatusId,
				[ModifiedBy] = @UserId, 
				[ModifiedDate] = @CurrentDateTime
 WHERE 
  [StudentEnquiryId]= @StudentEnquiryId
  END 
  ELSE
  BEGIN --INSERT Statement
INSERT INTO StudentEnquiry(
				[EnquiryDate],
				[StudentFirstName],
				[StudentMiddleName],
				[StudentLastName],
				[Gender],
				[BirthDate],
				[AdharNo],
				[Religion],
				[Cast],
				[Category],
				[Nationality],
				[MobileNumber],
				[InterestedClassId],
				[AcademicYearId],
				[CurrentSchool],
				[CurrentClass],
				[NameOfSiblingInCurrentSchool],
				[FatherFirstName],
				[FatherMiddleName],
				[FatherLastName],
				[MotherFirstName],
				[MotherMiddleName],
				[MotherLastName],
				[AddressLine1],
				[AddressLine2],
				[CountryId],
				[CountryName],
				[StateId],
				[StateName],
				[TalukaId],
				[TalukaName],
				[DistrictId],
				[DistrictName],
				[EmailId],
				[ReferenceBy],
				[EnquiryTypeId],
				[EnquiryStatusId],
				[CreatedBy],
				[CreatedDate]
	) 
  VALUES 
  (
				@EnquiryDate,
				@StudentFirstName,
				@StudentMiddleName,
				@StudentLastName,
				@Gender,
				@BirthDate,
				@AdharNo,
				@Religion,
				@Cast,
				@Category,
				@Nationality,
				@MobileNumber,
				@InterestedClassId,
				@AcademicYearId,
				@CurrentSchool,
				@CurrentClass,
				@NameOfSiblingInCurrentSchool,
				@FatherFirstName,
				@FatherMiddleName,
				@FatherLastName,
				@MotherFirstName,
				@MotherMiddleName,
				@MotherLastName,
				@AddressLine1,
				@AddressLine2,
				@CountryId,
				@CountryName,
				@StateId,
				@StateName,
				@TalukaId,
				@TalukaName,
				@DistrictId,
				@DistrictName,
				@EmailId,
				@ReferenceBy,
				@EnquiryTypeId,
				@EnquiryStatusId,
				@UserId,
				@CurrentDateTime
  ) 
  SET @StudentEnquiryId = SCOPE_IDENTITY();
  END 
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