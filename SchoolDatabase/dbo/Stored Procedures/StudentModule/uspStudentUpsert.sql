-- =============================================
-- Author:    Deepak Walunj
-- Create date: 05/08/2023
-- Description:  This stored procedure is used insert student profile
-- =============================================
CREATE PROCEDURE [dbo].uspStudentUpsert (
  @StudentId BIGINT, 
  @GeneralRegistrationNo NVARCHAR(100), 
  @CbscStudentId NVARCHAR(50),
  @AdmissionNo NVARCHAR(100), 
  @SchoolId SMALLINT, 
  @FirstName NVARCHAR(50), 
  @MiddleName NVARCHAR(50), 
  @LastName NVARCHAR(50), 
  @Gender NVARCHAR(5), 
  @AdharNo NVARCHAR(20), 
  @Religion NVARCHAR(50), 
  @Category NVARCHAR(50), 
  @Cast NVARCHAR(50), 
  @SubCast NVARCHAR(50), 
  @Nationality NVARCHAR(50), 
  @MotherTounge NVARCHAR(50), 
  @EmergencyContactPersonName NVARCHAR(100), 
  @EmergencyContactNumber NVARCHAR(20), 
  @FamilyDoctorName NVARCHAR(100), 
  @FamilyDoctorContactNumber NVARCHAR(20), 
  @BirthPlace NVARCHAR(100), 
  @BirthDate DATE, 
  @BirthDateInWords NVARCHAR(200), 
  @BirthCountryId INT, 
  @BirthStateId INT, 
  @BirthDistrictId INT, 
  @BirthTalukaId INT,
  @BirthTalukaName NVARCHAR(100), 
  @BirthDistrictName NVARCHAR(100), 
  @BirthStateName NVARCHAR(100), 
  @BirthCountryName NVARCHAR(100), 
  @BloodGroup NVARCHAR(5), 
  @Height NVARCHAR(10), 
  @Weight NVARCHAR(10), 
  @CurrentAddressLine1 NVARCHAR (250),
  @CurrentAddressLine2 NVARCHAR (250), 
  @CurrentTalukaId INT, 
  @CurrentDistrictId INT, 
  @CurrentStateId INT, 
  @CurrentCountryId INT,
  @CurrentTalukaName NVARCHAR(100), 
  @CurrentDistrictName NVARCHAR(100), 
  @CurrentStateName NVARCHAR(100), 
  @CurrentCountryName NVARCHAR(100),
  @CurrentZipcode NVARCHAR(10),
  @MedicalHistory NVARCHAR(500), 
  @AdmissionGrade NVARCHAR(10), 
  @DateOfAdmission DATE, 
  @LastSchoolAttended NVARCHAR(500), 
  @LastSchoolStandard NVARCHAR(10), 
  @LastSchoolDivision NVARCHAR(10), 
  @ProgressNoteFromLastSchool NVARCHAR(500), 
  @ConductNoteFromLastSchool NVARCHAR(500), 
  @StandardInWhichLastStudyingSection NVARCHAR(50), 
  @SinceWhenStudyingInLastSchool NVARCHAR(50), 
  @ReasonOfLeavingSchoolLastSchool NVARCHAR(500), 
  @DateOfLeavingLastSchool DATE, 
  @RemarkFromLastSchool NVARCHAR(500), 
  @ProfileImageURL VARCHAR(100),
  @AcademicYearId SMALLINT,
  @ClassId INT,
  @GradeNameAdmission NVARCHAR(50),
  @RollNumber NVARCHAR(20),
  @IsNewStudent BIT, 
  @IsRTEStudent BIT, 
  @IsConsationApplicable BIT, 
  @ConsationAmount MONEY, 
  @isArchive BIT,
  @PreviousAcademicYearPendingFeeAmount MONEY,
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

  DECLARE @AppAccessOldMobileNo VARCHAR(20),@AppAccessOldUserId INT,
          @IsDifferentUserRoleExist BIT;
   DECLARE @GradeId INT;
   DECLARE @DivisionId INT;
	SELECT 
  @GradeId=sgdm.GradeId,
  @DivisionId=sgdm.DivisionId
 
FROM 
  dbo.SchoolGradeDivisionMatrix sgdm JOIN
  dbo.Grade g ON sgdm.GradeId=g.GradeId JOIN
  dbo.Division d ON sgdm.DivisionId=d.DivisionId
  WHERE sgdm.IsDeleted <> 1 AND sgdm.SchoolGradeDivisionMatrixId=@ClassId 
        AND sgdm.AcademicYearId = @AcademicYearId

  

   DECLARE @UpdateFlag INT=1;
 DECLARE @PaymentExist BIT;

BEGIN TRY 

IF @StudentId > 0 

BEGIN --Update Statement
  
  SET @AppAccessOldMobileNo=(SELECT TOP (1) AppAccessMobileNo 
                            FROM dbo.Student WHERE StudentId=@StudentId 
                            ORDER BY CreatedDate DESC);
 
    IF NOT EXISTS (SELECT 1 FROM dbo.StudentGradeDivisionMapping 
                            WHERE StudentId = @StudentId 
                            AND GradeId = @GradeId AND Divisionid =@Divisionid 
                            AND AcademicYearId=@AcademicYearId )
	BEGIN
		SELECT  @PaymentExist=dbo.udfStudentPaymentHistoryCheck(@AcademicYearId, @StudentId);
			IF @PaymentExist=1
				BEGIN
					SET @UpdateFlag=0;
				END
	END
	
  
 IF @UpdateFlag=1
 BEGIN
UPDATE 
  dbo.Student 
SET 
  [GeneralRegistrationNo] = @GeneralRegistrationNo, 
  [CbscStudentId] = @CbscStudentId,
  [AdmissionNo] = @AdmissionNo, 
  [GradeNameAdmission] = @GradeNameAdmission,
  [SchoolId] = @SchoolId, 
  [FirstName] = @FirstName, 
  [MiddleName] = @MiddleName, 
  [LastName] = @LastName, 
  [Gender] = @Gender, 
  [AdharNo] = @AdharNo, 
  [Religion] = @Religion, 
  [Category] = @Category, 
  [Cast] = @Cast, 
  [SubCast] = @SubCast, 
  [Nationality] = @Nationality, 
  [MotherTounge] = @MotherTounge, 
  [EmergencyContactPersonName] = @EmergencyContactPersonName, 
  [EmergencyContactNumber] = @EmergencyContactNumber, 
  [FamilyDoctorName] = @FamilyDoctorName, 
  [FamilyDoctorContactNumber] = @FamilyDoctorContactNumber, 
  [BirthPlace] = @BirthPlace, 
  [BirthDate] = @BirthDate, 
  [BirthDateInWords] = @BirthDateInWords, 
  [BirthCountryId] = @BirthCountryId, 
  [BirthStateId] = @BirthStateId, 
  [BirthDistrictId] = @BirthDistrictId, 
  [BirthTalukaId] = @BirthTalukaId, 
  [BirthCountryName] = @BirthCountryName, 
  [BirthStateName] =   @BirthStateName,
  [BirthDistrictName] =  @BirthDistrictName, 
  [BirthTalukaName] =  @BirthTalukaName,
  [CurrentAddressLine1] =@CurrentAddressLine1,
  [CurrentAddressLine2]=@CurrentAddressLine2, 
  [CurrentTalukaId]=@CurrentTalukaId, 
  [CurrentCountryId]=@CurrentCountryId, 
  [CurrentDistrictId]=@CurrentDistrictId, 
  [CurrentStateId]=@CurrentStateId , 
  [CurrentTalukaName]=@CurrentTalukaName, 
  [CurrentDistrictName]=@CurrentDistrictName, 
  [CurrentStateName]=@CurrentStateName, 
  [CurrentCountryName]=@CurrentCountryName,
  [CurrentZipcode]=@CurrentZipcode,
  [BloodGroup] = @BloodGroup, 
  [Height] = @Height, 
  [Weight] = @Weight, 
  [MedicalHistory] = @MedicalHistory, 
  [AdmissionGrade] = @AdmissionGrade, 
  [DateOfAdmission] = @DateOfAdmission, 
  [LastSchoolAttended] = @LastSchoolAttended, 
  [LastSchoolStandard] = @LastSchoolStandard, 
  [LastSchoolDivision] = @LastSchoolDivision, 
  [ProgressNoteFromLastSchool] = @ProgressNoteFromLastSchool, 
  [ConductNoteFromLastSchool] = @ConductNoteFromLastSchool, 
  [StandardInWhichLastStudyingSection] = @StandardInWhichLastStudyingSection, 
  [SinceWhenStudyingInLastSchool] = @SinceWhenStudyingInLastSchool, 
  [ReasonOfLeavingSchoolLastSchool] = @ReasonOfLeavingSchoolLastSchool, 
  [DateOfLeavingLastSchool] = @DateOfLeavingLastSchool, 
  [RemarkFromLastSchool] = @RemarkFromLastSchool, 
  [ProfileImageURL] = @ProfileImageURL,
  [IsNewStudent] = @IsNewStudent, 
  [IsArchive]=@isArchive,
  [PreviousAcademicYearPendingFeeAmount]=@PreviousAcademicYearPendingFeeAmount,
  [ModifiedBy] = @UserId, 
  [ModifiedDate] = @CurrentDateTime,
  [IsAppAccess] = @IsAppAccess,
  [AppAccessMobileNo] = @AppAccessMobileNo,
  [AppAccessOneTimePassword] = @AppAccessOneTimePassword
WHERE 
  StudentId = @StudentId 

  --update grade & division mapping
    UPDATE dbo.StudentGradeDivisionMapping 
    SET GradeId = @GradeId,
        DivisionId = @DivisionId,
        RollNumber = @RollNumber,
        IsRTEStudent = @IsRTEStudent, 
        IsConsationApplicable = @IsConsationApplicable, 
        ConsationAmount = @ConsationAmount 
    WHERE StudentId = @StudentId AND AcademicYearId = @AcademicYearId

	END
  --end
  -- insert user 
    /*
    UserTypeId = 1 ==> SuperAdmin
    UserTypeId = 2 ==> Admin
    UserTypeId = 3 ==> Teacher
    UserTypeId = 4 ==> Cleark
    UserTypeId = 5 ==> Parent
    UserTypeId = 6 ==> CabDriver
    */
  -- end
  END
  ELSE 
  BEGIN --INSERT Statement
  INSERT INTO dbo.Student(
    [GeneralRegistrationNo],[CbscStudentId], [AdmissionNo], 
    [SchoolId], [FirstName], [MiddleName], 
    [LastName], [Gender], [AdharNo], 
    [Religion], [Category], [Cast], [SubCast], 
    [Nationality], [MotherTounge], [EmergencyContactPersonName], 
    [EmergencyContactNumber], [FamilyDoctorName], 
    [FamilyDoctorContactNumber], [BirthPlace], 
    [BirthDate], [BirthDateInWords], 
    [BirthCountryId], [BirthStateId], 
    [BirthDistrictId], [BirthTalukaId], 
    [BirthCountryName], [BirthStateName], 
    [BirthDistrictName], [BirthTalukaName], 
    [CurrentAddressLine1],[CurrentAddressLine2],
    [CurrentCountryId], [CurrentStateId], 
    [CurrentDistrictId], [CurrentTalukaId], 
    [CurrentCountryName], [CurrentStateName], 
    [CurrentDistrictName], [CurrentTalukaName], 
	 [CurrentZipcode],
    [BloodGroup], [Height], [Weight], 
    [MedicalHistory], [AdmissionGrade], 
    [DateOfAdmission], [LastSchoolAttended], 
    [LastSchoolStandard], [LastSchoolDivision], 
    [ProgressNoteFromLastSchool], [ConductNoteFromLastSchool], 
    [StandardInWhichLastStudyingSection], 
    [SinceWhenStudyingInLastSchool], 
    [ReasonOfLeavingSchoolLastSchool], 
    [DateOfLeavingLastSchool], [RemarkFromLastSchool], 
    [ProfileImageURL],
    [IsNewStudent],
    [IsArchive],[PreviousAcademicYearPendingFeeAmount],[GradeNameAdmission],[CreatedBy], [CreatedDate],
    [IsAppAccess], [AppAccessMobileNo], [AppAccessOneTimePassword]
  ) 
VALUES 
  (
    @GeneralRegistrationNo,@CbscStudentId, @AdmissionNo, 
    @SchoolId, @FirstName, @MiddleName, 
    @LastName, @Gender, @AdharNo, @Religion, 
    @Category, @Cast, @SubCast, @Nationality, 
    @MotherTounge, @EmergencyContactPersonName, 
    @EmergencyContactNumber, @FamilyDoctorName, 
    @FamilyDoctorContactNumber, @BirthPlace, 
    @BirthDate, @BirthDateInWords, @BirthCountryId, 
    @BirthStateId, @BirthDistrictId, 
    @BirthTalukaId, @BirthCountryName, 
    @BirthStateName, @BirthDistrictName, 
    @BirthTalukaName, 
    @CurrentAddressLine1,@CurrentAddressLine2,
    @CurrentCountryId,@CurrentStateId, 
    @CurrentDistrictId,@CurrentTalukaId, 
    @CurrentCountryName,@CurrentStateName, 
    @CurrentDistrictName,@CurrentTalukaName,
	 @CurrentZipcode,
    @BloodGroup, @Height, 
    @Weight, @MedicalHistory, @AdmissionGrade, 
    @DateOfAdmission, @LastSchoolAttended, 
    @LastSchoolStandard, @LastSchoolDivision, 
    @ProgressNoteFromLastSchool, @ConductNoteFromLastSchool, 
    @StandardInWhichLastStudyingSection, 
    @SinceWhenStudyingInLastSchool, 
    @ReasonOfLeavingSchoolLastSchool, 
    @DateOfLeavingLastSchool, @RemarkFromLastSchool, 
    @ProfileImageURL,
    @IsNewStudent,@isArchive,@PreviousAcademicYearPendingFeeAmount, @GradeNameAdmission, @UserId, @CurrentDateTime,
    @IsAppAccess, @AppAccessMobileNo, @AppAccessOneTimePassword
  )
 

  SET @StudentId= SCOPE_IDENTITY();
  -- insert grade & division mapping
     INSERT INTO dbo.StudentGradeDivisionMapping(AcademicYearId,GradeId,
                    DivisionId,RollNumber, IsRTEStudent,IsConsationApplicable,ConsationAmount,StudentId,CreatedBy,CreatedDate)
     VALUES (@AcademicYearId,@GradeId,@DivisionId,@RollNumber,@IsRTEStudent, @IsConsationApplicable,@ConsationAmount, @StudentId,@UserId,@CurrentDateTime) 

  -- end
  -- insert user 
    /*
    UserTypeId = 1 ==> SuperAdmin
    UserTypeId = 2 ==> Admin
    UserTypeId = 3 ==> Teacher
    UserTypeId = 4 ==> Cleark
    UserTypeId = 5 ==> Parent
    UserTypeId = 6 ==> CabDriver
    */
  -- end
  SET @AppAccessOldMobileNo=@AppAccessMobileNo;
END

 SET @AppAccessOldUserId=(SELECT TOP (1) UserId 
                    FROM dbo.[User] WHERE MobileNumber=@AppAccessOldMobileNo 
                    AND Uname=@AppAccessOldMobileNo ORDER BY CreatedDate DESC);
  IF  EXISTS(SELECT 1 FROM dbo.Student 
                WHERE AppAccessMobileNo=@AppAccessOldMobileNo)
  BEGIN
    SET @IsDifferentUserRoleExist=1;
  END

EXEC dbo.uspUserUpsert 1,@AppAccessOldUserId,
                        @IsDifferentUserRoleExist,@AppAccessMobileNo,
                        @Upassword,@PasswordSalt,5,@UserId,
                        @FirstName,@LastName, @StudentId

  SELECT TOP (1) s.StudentId
  , p.ParentId AS FatherId,
  @UpdateFlag AS UpdateFlag
  , (SELECT TOP (1) fm.ParentId FROM dbo.ParentStudentMapping fm INNER JOIN
                dbo.Parent fp ON fm.ParentId =fp.ParentId 
                WHERE fm.StudentId = s.StudentId AND fp.ParentId = 12 
                AND fp.IsDeleted<>1 ORDER BY fp.CreatedDate DESC) AS MotherId
  , (SELECT TOP (1) fm.ParentId FROM dbo.ParentStudentMapping fm INNER JOIN
                dbo.Parent fp ON fm.ParentId =fp.ParentId 
                WHERE fm.StudentId = s.StudentId AND fp.ParentId = 13
                AND fp.IsDeleted<>1  ORDER BY fp.CreatedDate DESC) AS GuardianId
  FROM dbo.Student s 
  INNER JOIN dbo.StudentGradeDivisionMapping m ON s.StudentId=m.StudentId
  LEFT JOIN dbo.ParentStudentMapping pm ON s.StudentId = pm.StudentId
  LEFT JOIN dbo.Parent p ON pm.ParentId = p.ParentId
  WHERE
    ISNULL(s.IsDeleted,0)<>1 AND ISNULL(s.IsArchive,0)<>1 AND ISNULL(m.IsDeleted,0)<>1 AND m.AcademicYearId = @AcademicYearId 
    AND (p.ParentId IS NULL OR p.ParentTypeId = 11) AND ISNULL(p.IsDeleted,0) <> 1
    AND s.StudentId=@StudentId ORDER BY s.CreatedDate DESC;
     
END TRY
BEGIN CATCH DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
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