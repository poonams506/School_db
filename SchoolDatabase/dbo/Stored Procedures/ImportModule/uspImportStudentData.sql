--===============================================
-- Author:    Meena Kotkar
-- Create date: 4/12/2023
-- Description:  This stored procedure is used Import Student Data
-- =============================================
CREATE PROC dbo.uspImportStudentData(
  @StudentImportType StudentImportType READONLY,
  @UserId INT,
  @schoolCode NVARCHAR(20)
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 

  DECLARE @CurrentDateTime DATETIME = GETDATE();
  DECLARE @StudentTempTable TABLE (StudentId BIGINT,FirstName NVARCHAR(50),MiddleName NVARCHAR(50),LastName NVARCHAR(50),BirthDate DateTime, ActionTaken NVARCHAR(10))
  DECLARE  @ParentTempTable TABLE (StudentId BIGINT,ParentId BIGINT, ParentTypeId SMALLINT);
  DECLARE @InsertedCount INT;
  DECLARE @UpdatedCount INT;
  
  BEGIN TRY 
    
	MERGE dbo.Student AS Target
	USING (SELECT DISTINCT ST.Gen_Reg_No,ST.CBSC_Student_Id,ST.Admission_No,
        ST.Student_First_Name,ST.Student_Middle_Name,ST.Student_Last_Name,
        ST.Gender, ST.Adhaar_No,ST.Religion,ST.Category,ST.Cast,ST.Sub_Caste,
        ST.Nationality,ST.Mother_Tongue,ST.Emergency_Contact_Person_Name,
        ST.Emergency_Contact_No,ST.Family_Doctor_Name,
        ST.Family_Doctor_No,ST.Birth_Place,
        ST.BirthDate,ST.Date_Of_Birth_In_Words,
        ST.Birth_Country,ST.Birth_State,
        ST.Birth_District,ST.Birth_Taluka,
        ST.Current_Address_Line_1,ST.Current_Address_Line_2,
        ST.Current_Country,ST.Current_State,
        ST.Current_District,ST.Current_Taluka,
         ST.Current_Pincode,
         ST.Blood_Group,ST.Height,ST.Weight,
         ST.Medical_History_Notes,
         ST.Admission_Date,ST.Previous_School_Name,
         ST.Previous_School_Standard,ST.Previous_School_Division,
         ST.Progress_Note_From_Last_School,ST.Conduct_Note_From_Last_School,
         ST.Reason_of_Leaving_School,
         ST.Date_of_Leaving_of_Previous_School,ST.Remark,
         ST.Is_New_Student,ST.Is_RTE,ST.Is_Deactive,
         ST.Apply_Concession,ST.Concession_Fee,ST.PreviousAcademicYearPendingFeeAmount,
         ST.Do_you_required_parent_mobile_app_access,ST.Mobile_Number_for_Application_Access,
		 S.SchoolId,
		 ST.Current_CountryId AS CurrentCountryId,
		 ST.Current_StateId AS CurrentStateId ,
		 ST. Current_DistrictId CurrentDistrictId,
		 ST.Current_TalukaId AS CurrentTalukaId,
		  ST.Birth_CountryId AS BirthCountryId, 
		  ST.Birth_StateId AS BirthStateId, 
		  ST.Birth_DistrictId AS BirthDistrictId, 
		  ST.Birth_TalukaId AS BirthTalukaId


		 FROM  @StudentImportType ST 
		INNER JOIN dbo.School AS S ON S.SchoolCode=@schoolCode
		) AS Source
		ON CONCAT(Target.FirstName,Target.MiddleName,Target.LastName)=CONCAT(Source.Student_First_Name,Source.Student_Middle_Name,Source.Student_Last_Name)
		AND CONVERT(DATETIME,Target.BirthDate, 105)=CONVERT(DATETIME,Source.BirthDate, 105) AND ISNULL(Target.isDeleted,0)=0
		WHEN NOT MATCHED BY Target THEN    
	INSERT  (GeneralRegistrationNo,CbscStudentId, AdmissionNo, 
    FirstName, MiddleName, 
    LastName, Gender, AdharNo, 
    Religion, Category, Cast, SubCast, 
    Nationality, MotherTounge, EmergencyContactPersonName, 
    EmergencyContactNumber, FamilyDoctorName, 
    FamilyDoctorContactNumber, BirthPlace, 
    BirthDate, BirthDateInWords,  
    BirthCountryName, BirthStateName, 
    BirthDistrictName, BirthTalukaName, 
	BirthCountryId,BirthStateId,BirthDistrictId,BirthTalukaId,
    CurrentAddressLine1,CurrentAddressLine2,
    CurrentCountryName, CurrentStateName, 
    CurrentDistrictName, CurrentTalukaName, 
    CurrentCountryId,CurrentStateId ,CurrentDistrictId,CurrentTalukaId,
	CurrentZipcode,
    BloodGroup, Height, Weight, 
    MedicalHistory,
    DateOfAdmission, LastSchoolAttended, 
    LastSchoolStandard, LastSchoolDivision, 
    ProgressNoteFromLastSchool, ConductNoteFromLastSchool, 
    ReasonOfLeavingSchoolLastSchool, 
    DateOfLeavingLastSchool, RemarkFromLastSchool, 
    IsNewStudent, IsArchive,PreviousAcademicYearPendingFeeAmount,
	SchoolId,
    CreatedBy, CreatedDate,
    IsAppAccess, AppAccessMobileNo)
    VALUES (Source.Gen_Reg_No,Source.CBSC_Student_Id,Source.Admission_No,
        Source.Student_First_Name,Source.Student_Middle_Name,Source.Student_Last_Name,
        Source.Gender, Source.Adhaar_No,Source.Religion,Source.Category,Source.Cast,Source.Sub_Caste,
        Source.Nationality,Source.Mother_Tongue,Source.Emergency_Contact_Person_Name,
        Source.Emergency_Contact_No,Source.Family_Doctor_Name,
        Source.Family_Doctor_No,Source.Birth_Place,
        CONVERT(DATETIME,Source.BirthDate, 105),Source.Date_Of_Birth_In_Words,
        Source.Birth_Country,Source.Birth_State,
        Source.Birth_District,Source.Birth_Taluka,
		Source.BirthCountryId,Source.BirthStateId,Source.BirthDistrictId,Source.BirthTalukaId,
		Source.Current_Address_Line_1,Source.Current_Address_Line_2,
        Source.Current_Country,Source.Current_State,
        Source.Current_District,Source.Current_Taluka,
		Source.CurrentCountryId,Source.CurrentStateId,Source.CurrentDistrictId,Source.CurrentTalukaId,
         Source.Current_Pincode,
         Source.Blood_Group,Source.Height,Source.Weight,
         Source.Medical_History_Notes,
         CONVERT(DATETIME,Source.Admission_Date, 105),Source.Previous_School_Name,
         Source.Previous_School_Standard,Source.Previous_School_Division,
         Source.Progress_Note_From_Last_School,Source.Conduct_Note_From_Last_School,
         Source.Reason_of_Leaving_School,
         CONVERT(DATETIME,Source.Date_of_Leaving_of_Previous_School, 105),Source.Remark,
         Source.Is_New_Student,Source.Is_Deactive,Source.PreviousAcademicYearPendingFeeAmount,
         Source.SchoolId,
         @UserId,@CurrentDateTime,
         Source.Do_you_required_parent_mobile_app_access,Source.Mobile_Number_for_Application_Access)

		WHEN MATCHED THEN UPDATE SET
		Target.GeneralRegistrationNo=Source.Gen_Reg_No,
		Target.CbscStudentId=Source.CBSC_Student_Id,
		Target.AdmissionNo=Source.Admission_No,
        Target.FirstName=Source.Student_First_Name,
		Target.MiddleName=Source.Student_Middle_Name,
		Target.LastName=Source.Student_Last_Name,
        Target.Gender=Source.Gender, 
		Target.AdharNo=Source.Adhaar_No,
		Target.Religion=Source.Religion,
		Target.Category=Source.Category,
		Target.Cast=Source.Cast,
		Target.SubCast=Source.Sub_Caste,
        Target.Nationality=Source.Nationality,
		Target.MotherTounge=Source.Mother_Tongue,
		Target.EmergencyContactPersonName=Source.Emergency_Contact_Person_Name,
        Target.EmergencyContactNumber=Source.Emergency_Contact_No,
		Target.FamilyDoctorName=Source.Family_Doctor_Name,
        Target.FamilyDoctorContactNumber=Source.Family_Doctor_No,
		Target.BirthPlace=Source.Birth_Place,
        Target.BirthDate=CONVERT(DATETIME,Source.BirthDate , 105),
		Target.BirthDateInWords=Source.Date_Of_Birth_In_Words,
        Target.BirthCountryName=Source.Birth_Country,
		Target.BirthStateName=Source.Birth_State,
        Target.BirthDistrictName=Source.Birth_District,
		Target.BirthTalukaName=Source.Birth_Taluka,
		Target.BirthCountryId=Source.BirthCountryId,
		Target.BirthStateId=Source.BirthStateId,
        Target.BirthDistrictId=Source.BirthDistrictId,
		Target.BirthTalukaId=Source.BirthTalukaId,
        Target.CurrentAddressLine1=Source.Current_Address_Line_1,
		Target.CurrentAddressLine2=Source.Current_Address_Line_2,
        Target.CurrentCountryName=Source.Current_Country,
		Target.CurrentStateName=Source.Current_State,
        Target.CurrentDistrictName=Source.Current_District,
		Target.CurrentTalukaName=Source.Current_Taluka,
		Target.CurrentCountryId=Source.CurrentCountryId,
		Target.CurrentStateId=Source.CurrentStateId,
        Target.CurrentDistrictId=Source.CurrentDistrictId,
		Target.CurrentTalukaId=Source.CurrentTalukaId,
        Target.CurrentZipcode=Source.Current_Pincode,
        Target.BloodGroup=Source.Blood_Group,
		 Target.Height=Source.Height,
		 Target.Weight=Source.Weight,
         Target.MedicalHistory=Source.Medical_History_Notes,
         Target.DateOfAdmission=CONVERT(DATETIME,Source.Admission_Date, 105),
		 Target.LastSchoolAttended=Source.Previous_School_Name,
         Target.LastSchoolStandard=Source.Previous_School_Standard,
		 Target.LastSchoolDivision=Source.Previous_School_Division,
         Target.ProgressNoteFromLastSchool=Source.Progress_Note_From_Last_School,
		 Target.ConductNoteFromLastSchool=Source.Conduct_Note_From_Last_School,
         Target.ReasonOfLeavingSchoolLastSchool=Source.Reason_of_Leaving_School,
         Target.DateOfLeavingLastSchool=CONVERT(DATETIME,Source.Date_of_Leaving_of_Previous_School, 105),
		 Target.RemarkFromLastSchool=Source.Remark,
         Target.IsNewStudent=Source.Is_New_Student,
         Target.IsArchive=Source.Is_Deactive,
         Target.PreviousAcademicYearPendingFeeAmount=Source.PreviousAcademicYearPendingFeeAmount,
		 Target.SchoolId=Source.SchoolId,
         Target.ModifiedBy=@UserId,
		 Target.ModifiedDate=@CurrentDateTime,
         Target.IsAppAccess=Source.Do_you_required_parent_mobile_app_access,
		 Target.AppAccessMobileNo=Source.Mobile_Number_for_Application_Access

		 OUTPUT INSERTED.StudentId ,INSERTED.FirstName,INSERTED.MiddleName,INSERTED.LastName ,INSERTED.BirthDate ,$action into @StudentTempTable;
		  -- Get the counts
        SELECT @InsertedCount = COUNT(*) FROM @StudentTempTable WHERE ActionTaken = 'INSERT';
        SELECT @UpdatedCount = COUNT(*) FROM @StudentTempTable WHERE ActionTaken = 'UPDATE';

		MERGE dbo.StudentGradeDivisionMapping AS Target
		USING (SELECT DISTINCT T.StudentId,
        (Select TOP 1 AcademicYearId FROM dbo.AcademicYear WHERE AcademicYearName = ST.Academic_Year) as AcademicYearId,
        (Select TOP 1 GradeId FROM dbo.Grade WHERE GradeName = ST.Grade) as GradeId,
        (Select TOP 1 DivisionId FROM dbo.Division WHERE DivisionName = ST.Division) as DivisionId,
		ST.Roll_No as RollNumber,ST.Is_RTE,ST.Apply_Concession,ST.Concession_Fee FROM  @StudentImportType ST
		INNER JOIN @StudentTempTable AS T ON CONCAT(T.FirstName,T.MiddleName,T.LastName) = CONCAT(ST.Student_First_Name,ST.Student_Middle_Name,ST.Student_Last_Name)
		AND T.BirthDate=ST.BirthDate
		) as Source ON Target.StudentId=Source.StudentId AND Target.AcademicYearId = Source.AcademicYearId
		
		WHEN NOT MATCHED  THEN  
    	INSERT(AcademicYearId, StudentId, GradeId, DivisionId, RollNumber, IsRTEStudent,IsConsationApplicable, ConsationAmount, CreatedBy, CreatedDate) 
		VALUES(Source.AcademicYearId , Source.StudentId, Source.GradeId, Source.DivisionId, Source.RollNumber, Source.Is_RTE, Source.Apply_Concession,Source.Concession_Fee, @UserId, @CurrentDateTime)
		WHEN MATCHED THEN 
		UPDATE SET
		Target.AcademicYearId=Source.AcademicYearId,
		Target.StudentId=Source.StudentId,
		Target.GradeId=Source.GradeId,
		Target.DivisionId=Source.DivisionId,
		Target.RollNumber=Source.RollNumber,
		Target.IsRTEStudent=Source.Is_RTE,
        Target.IsConsationApplicable=Source.Apply_Concession,
		Target.ConsationAmount=Source.Concession_Fee,
		Target.ModifiedBy=@UserId,
		Target.ModifiedDate=@CurrentDateTime;


		MERGE dbo.Parent AS Target
		USING (SELECT DISTINCT T.StudentId,ST.Father_First_Name,ST.Father_Middle_Name,
       ST.Father_Last_Name,ST.Father_Gender,ST.Father_Mobile_No,
       ST.Father_Alternate_Contact_No,ST.Father_Email_Id,ST.Father_Address_Line_1,
       ST.Father_Address_Line_2,
       ST.Father_Taluka,ST.Father_District,ST.Father_State,ST.Father_Country,
       ST.Father_Pincode,
       ST.Father_Adhaar_No,ST.Father_Education,ST.Father_Birth_Date,
       ST.Father_Occupation,ST.Father_Annual_Income,ST.Father_Blood_Group ,
		ST.Father_CountryId  AS CountryId,
		ST.Father_StateId  AS StateId,
		ST.Father_DistrictId AS DistrictId,
		ST.Father_TalukaId  AS TalukaId,
        p.ParentId
	   FROM  @StudentImportType ST
		INNER JOIN @StudentTempTable AS T ON CONCAT(T.FirstName,T.MiddleName,T.LastName) = CONCAT(ST.Student_First_Name,ST.Student_Middle_Name,ST.Student_Last_Name)
		AND T.BirthDate=ST.BirthDate
		OUTER APPLY (SELECT psm.ParentId FROM	dbo.ParentStudentMapping psm 
		 JOIN dbo.Parent p ON psm.ParentId=p.ParentId AND p.ParentTypeId=11
		 WHERE  T.StudentId=psm.StudentId 
		 ) p
		) as Source ON Target.ParentId=Source.ParentId AND Target.ParentTypeId=11 AND ISNULL(Target.isDeleted,0)=0

		WHEN NOT MATCHED  THEN  
		 INSERT(
       ParentTypeId, FirstName, MiddleName, 
       LastName, Gender,  MobileNumber, 
	   ContactNumber,EmailId, AddressLine1, 
       AddressLine2, 
	   TalukaId,DistrictId, StateId, CountryId,
       TalukaName, DistrictName, StateName, CountryName,
       Zipcode, 
       AdharNumber, Education, BirthDate, 
       Occupation, AnnualIncome, BloodGroup, 
       CreatedBy,CreatedDate
       ) 
       Values( 11,Source.Father_First_Name,Source.Father_Middle_Name,
       Source.Father_Last_Name,Source.Father_Gender,Source.Father_Mobile_No,
       Source.Father_Alternate_Contact_No,Source.Father_Email_Id,Source.Father_Address_Line_1,
       Source.Father_Address_Line_2,
	   Source.TalukaId, Source.DistrictId, Source.StateId, Source.CountryId,
       Source.Father_Taluka,Source.Father_District,Source.Father_State,Source.Father_Country,
       Source.Father_Pincode,
       Source.Father_Adhaar_No,Source.Father_Education,Source.Father_Birth_Date,
       Source.Father_Occupation,Source.Father_Annual_Income,Source.Father_Blood_Group,@UserId,@CurrentDateTime
      )
	  WHEN MATCHED THEN 
	  UPDATE SET
		 Target.ParentTypeId = 11, 
         Target.FirstName = Source.Father_First_Name, 
         Target.MiddleName = Source.Father_Middle_Name, 
         Target.LastName = Source.Father_Last_Name, 
         Target.Gender = Source.Father_Gender, 
         Target.ContactNumber = Source.Father_Alternate_Contact_No, 
         Target.MobileNumber = Source.Father_Mobile_No, 
         Target.EmailId = Source.Father_Email_Id, 
         Target.AddressLine1 = Source.Father_Address_Line_1, 
         Target.AddressLine2 = Source.Father_Address_Line_2, 
         Target.TalukaId = Source.TalukaId, 
         Target.DistrictId = Source.DistrictId, 
         Target.StateId = Source.StateId, 
         Target.CountryId = Source.CountryId, 
         Target.TalukaName = Source.Father_Taluka,
         Target.DistrictName = Source.Father_District,
         Target.StateName = Source.Father_State,
         Target.CountryName = Source.Father_Country,
         Target.Zipcode = Source.Father_Pincode, 
         Target.AdharNumber = Source.Father_Adhaar_No, 
         Target.Education = Source.Father_Education, 
         Target.BirthDate = Source.Father_Birth_Date, 
         Target.Occupation =Source. Father_Occupation, 
         Target.AnnualIncome = Source.Father_Annual_Income, 
         Target.BloodGroup = Source.Father_Blood_Group,  
         Target.ModifiedBy = @UserId, 
         Target.ModifiedDate = @CurrentDateTime

		 OUTPUT Source.StudentId ,INSERTED.ParentId ,INSERTED.ParentTypeId into @ParentTempTable;

		 MERGE dbo.Parent AS Target
		USING (SELECT DISTINCT T.StudentId, ST.Mother_First_Name,ST.Mother_Middle_Name,
       ST.Mother_Last_Name,ST.Mother_Gender,ST.Mother_Mobile_No,
       ST.Mother_Alternate_Contact_No,ST.Mother_Email_Id,ST.Mother_Address_Line_1,
       ST.Mother_Address_Line_2,
       ST.Mother_Taluka,ST.Mother_District,ST.Mother_State,ST.Mother_Country,
       ST.Mother_Pincode,
       ST.Mother_Adhaar_No,ST.Mother_Education,ST.Mother_Birth_Date,
       ST.Mother_Occupation,ST.Mother_Annual_Income,ST.Mother_Blood_Group ,
	   ST.Mother_CountryId  AS CountryId,
		ST.Mother_StateId AS StateId,
		ST.Mother_DistrictId AS DistrictId,
		ST.Mother_TalukaId AS TalukaId,
	   p.ParentId
	   FROM  @StudentImportType ST
		INNER JOIN @StudentTempTable AS T ON CONCAT(T.FirstName,T.MiddleName,T.LastName) = CONCAT(ST.Student_First_Name,ST.Student_Middle_Name,ST.Student_Last_Name)
		AND T.BirthDate=ST.BirthDate
		OUTER APPLY (SELECT psm.ParentId FROM	dbo.ParentStudentMapping psm 
		 JOIN dbo.Parent p ON psm.ParentId=p.ParentId AND p.ParentTypeId=12
		 WHERE  T.StudentId=psm.StudentId 
		 ) p
		) as Source ON Target.ParentId=Source.ParentId AND Target.ParentTypeId=12 AND Target.isDeleted=0

		WHEN NOT MATCHED  THEN  
		 INSERT(
       ParentTypeId, FirstName, MiddleName, 
       LastName, Gender,  MobileNumber, 
	   ContactNumber,EmailId, AddressLine1, 
       AddressLine2, 
	   TalukaId,DistrictId, StateId, CountryId,
       TalukaName, DistrictName, StateName, CountryName,
       Zipcode, 
       AdharNumber, Education, BirthDate, 
       Occupation, AnnualIncome, BloodGroup, 
       CreatedBy,CreatedDate
       ) 
       Values( 12,Source.Mother_First_Name,Source.Mother_Middle_Name,
       Source.Mother_Last_Name,Source.Mother_Gender,Source.Mother_Mobile_No,
       Source.Mother_Alternate_Contact_No,Source.Mother_Email_Id,Source.Mother_Address_Line_1,
       Source.Mother_Address_Line_2,
	   Source.TalukaId, Source.DistrictId, Source.StateId, Source.CountryId,
       Source.Mother_Taluka,Source.Mother_District,Source.Mother_State,Source.Mother_Country,
       Source.Mother_Pincode,
       Source.Mother_Adhaar_No,Source.Mother_Education,Source.Mother_Birth_Date,
       Source.Mother_Occupation,Source.Mother_Annual_Income,Source.Mother_Blood_Group,@UserId,@CurrentDateTime
      )
	  WHEN MATCHED THEN 
	  UPDATE SET
		 Target.ParentTypeId = 12, 
         Target.FirstName = Source.Mother_First_Name, 
         Target.MiddleName = Source.Mother_Middle_Name, 
         Target.LastName = Source.Mother_Last_Name, 
         Target.Gender = Source.Mother_Gender, 
         Target.ContactNumber = Source.Mother_Alternate_Contact_No, 
         Target.MobileNumber = Source.Mother_Mobile_No, 
         Target.EmailId = Source.Mother_Email_Id, 
         Target.AddressLine1 = Source.Mother_Address_Line_1, 
         Target.AddressLine2 = Source.Mother_Address_Line_2, 
         Target.TalukaId = Source.TalukaId, 
         Target.DistrictId = Source.DistrictId, 
         Target.StateId = Source.StateId, 
         Target.CountryId = Source.CountryId, 
         Target.TalukaName = Source.Mother_Taluka,
         Target.DistrictName = Source.Mother_District,
         Target.StateName = Source.Mother_State,
         Target.CountryName = Source.Mother_Country,
         Target.Zipcode = Source.Mother_Pincode, 
         Target.AdharNumber = Source.Mother_Adhaar_No, 
         Target.Education = Source.Mother_Education, 
         Target.BirthDate = Source.Mother_Birth_Date, 
         Target.Occupation =Source. Mother_Occupation, 
         Target.AnnualIncome = Source.Mother_Annual_Income, 
         Target.BloodGroup = Source.Mother_Blood_Group,  
         Target.ModifiedBy = @UserId, 
         Target.ModifiedDate = @CurrentDateTime

		 OUTPUT Source.StudentId ,INSERTED.ParentId ,INSERTED.ParentTypeId into @ParentTempTable;


		  MERGE dbo.Parent AS Target
		USING (SELECT DISTINCT T.StudentId,ST.Guardian_First_Name,ST.Guardian_Middle_Name,
       ST.Guardian_Last_Name,ST.Guardian_Gender,ST.Guardian_Mobile_No,
       ST.Guardian_Alternate_Contact_No,ST.Guardian_Email_Id,ST.Guardian_Address_Line_1,
       ST.Guardian_Address_Line_2,
       ST.Guardian_Taluka,ST.Guardian_District,ST.Guardian_State,ST.Guardian_Country,
       ST.Guardian_Pincode,
       ST.Guardian_Adhaar_No,ST.Guardian_Education,ST.Guardian_Birth_Date,
       ST.Guardian_Occupation,ST.Guardian_Annual_Income,ST.Guardian_Blood_Group ,
       ST.Gaurdian_CountryId AS CountryId,
		ST.Gaurdian_StateId AS StateId,
		ST.Gaurdian_DistrictId AS DistrictId,
		ST.Gaurdian_TalukaId AS TalukaId,
	   p.ParentId
	   FROM  @StudentImportType ST
		INNER JOIN @StudentTempTable AS T ON CONCAT(T.FirstName,T.MiddleName,T.LastName) = CONCAT(ST.Student_First_Name,ST.Student_Middle_Name,ST.Student_Last_Name) AND ST.Guardian_First_Name IS NOT NULL AND ST.Guardian_Last_Name IS NOT NULL
		AND T.BirthDate=ST.BirthDate
		OUTER APPLY (SELECT psm.ParentId FROM	dbo.ParentStudentMapping psm 
		 JOIN dbo.Parent p ON psm.ParentId=p.ParentId AND p.ParentTypeId=13
		 WHERE  T.StudentId=psm.StudentId 
		 ) p
		) as Source ON Target.ParentId=Source.ParentId AND Target.ParentTypeId=13 AND ISNULL(Target.isDeleted,0)=0 
		WHEN NOT MATCHED 
		THEN  
		 INSERT(
       ParentTypeId, FirstName, MiddleName, 
       LastName, Gender,  MobileNumber, 
	   ContactNumber,EmailId, AddressLine1, 
       AddressLine2, 
	   TalukaId,DistrictId, StateId, CountryId,
       TalukaName, DistrictName, StateName, CountryName,
       Zipcode, 
       AdharNumber, Education, BirthDate, 
       Occupation, AnnualIncome, BloodGroup, 
       CreatedBy,CreatedDate
       ) 
       Values( 13,Source.Guardian_First_Name,Source.Guardian_Middle_Name,
       Source.Guardian_Last_Name,Source.Guardian_Gender,Source.Guardian_Mobile_No,
       Source.Guardian_Alternate_Contact_No,Source.Guardian_Email_Id,Source.Guardian_Address_Line_1,
       Source.Guardian_Address_Line_2,
	   Source.TalukaId, Source.DistrictId, Source.StateId, Source.CountryId,
       Source.Guardian_Taluka,Source.Guardian_District,Source.Guardian_State,Source.Guardian_Country,
       Source.Guardian_Pincode,
       Source.Guardian_Adhaar_No,Source.Guardian_Education,Source.Guardian_Birth_Date,
       Source.Guardian_Occupation,Source.Guardian_Annual_Income,Source.Guardian_Blood_Group,@UserId,@CurrentDateTime
      ) 
	  WHEN MATCHED 
	  THEN 
	  UPDATE SET
		 Target.ParentTypeId = 13, 
         Target.FirstName = Source.Guardian_First_Name, 
         Target.MiddleName = Source.Guardian_Middle_Name, 
         Target.LastName = Source.Guardian_Last_Name, 
         Target.Gender = Source.Guardian_Gender, 
         Target.ContactNumber = Source.Guardian_Alternate_Contact_No, 
         Target.MobileNumber = Source.Guardian_Mobile_No, 
         Target.EmailId = Source.Guardian_Email_Id, 
         Target.AddressLine1 = Source.Guardian_Address_Line_1, 
         Target.AddressLine2 = Source.Guardian_Address_Line_2, 
         Target.TalukaId = Source.TalukaId, 
         Target.DistrictId = Source.DistrictId, 
         Target.StateId = Source.StateId, 
         Target.CountryId = Source.CountryId, 
         Target.TalukaName = Source.Guardian_Taluka,
         Target.DistrictName = Source.Guardian_District,
         Target.StateName = Source.Guardian_State,
         Target.CountryName = Source.Guardian_Country,
         Target.Zipcode = Source.Guardian_Pincode, 
         Target.AdharNumber = Source.Guardian_Adhaar_No, 
         Target.Education = Source.Guardian_Education, 
         Target.BirthDate = Source.Guardian_Birth_Date, 
         Target.Occupation =Source. Guardian_Occupation, 
         Target.AnnualIncome = Source.Guardian_Annual_Income, 
         Target.BloodGroup = Source.Guardian_Blood_Group,  
         Target.ModifiedBy = @UserId, 
         Target.ModifiedDate = @CurrentDateTime

		 OUTPUT Source.StudentId ,INSERTED.ParentId ,INSERTED.ParentTypeId into @ParentTempTable;

		 MERGE dbo.ParentStudentMapping  AS Target
		USING (SELECT T.StudentId,PT.ParentId,PT.ParentTypeId FROM  @StudentImportType ST
		INNER JOIN @StudentTempTable AS T ON CONCAT(T.FirstName,T.MiddleName,T.LastName) = CONCAT(ST.Student_First_Name,ST.Student_Middle_Name,ST.Student_Last_Name)
		AND T.BirthDate=ST.BirthDate
		INNER JOIN  @ParentTempTable AS PT ON T.StudentId= PT.StudentId
		INNER JOIN dbo.Parent p ON PT.ParentId=p.ParentId
		) as Source ON Target.StudentId=Source.StudentId AND Target.ParentId=Source.ParentId

		WHEN NOT MATCHED THEN 
		INSERT (ParentId,StudentId)
		VALUES(Source.ParentId,Source.StudentId)

		WHEN MATCHED THEN
		UPDATE SET
		Target.ParentId=Source.ParentId,
		Target.StudentId=Source.StudentId;


        -- Insert app users
        -- Declare cursor
        
        DECLARE @Student_First_Name NVARCHAR(100), @Student_Middle_Name NVARCHAR(100),@Student_Last_Name NVARCHAR(100),@BirthDate DateTime,
        @Do_you_required_parent_mobile_app_access BIT, @AppAccessOneTimePassword NVARCHAR(1000), @PasswordSalt NVARCHAR(1000), @Upassword NVARCHAR(1000), 
        @Mobile_Number_for_Application_Access NVARCHAR(100)
        DECLARE student_cursor CURSOR FOR
        SELECT Student_First_Name,Student_Middle_Name,Student_Last_Name,BirthDate,
        Do_you_required_parent_mobile_app_access,AppAccessOneTimePassword,PasswordSalt,Upassword, Mobile_Number_for_Application_Access
        FROM @StudentImportType

        -- Open the cursor
        OPEN student_cursor

        -- Fetch the first row into variables
        FETCH NEXT FROM student_cursor INTO @Student_First_Name, @Student_Middle_Name, @Student_Last_Name, @BirthDate,
        @Do_you_required_parent_mobile_app_access, @AppAccessOneTimePassword, @PasswordSalt, @Upassword, @Mobile_Number_for_Application_Access

        -- Loop through the cursor
        WHILE @@FETCH_STATUS = 0
        BEGIN
            DECLARE @AppAccessOldMobileNo VARCHAR(20),@AppAccessOldUserId INT, @IsDifferentUserRoleExist BIT, @RefId INT;

            IF @Do_you_required_parent_mobile_app_access = 1
            BEGIN
                SET @AppAccessOldMobileNo=(SELECT TOP 1 AppAccessMobileNo FROM dbo.Student WHERE FirstName = @Student_First_Name AND MiddleName = @Student_Middle_Name AND
                                            LastName = @Student_Last_Name AND CONVERT (VARCHAR(100),BirthDate, 105) =CONVERT (VARCHAR(100),@BirthDate, 105) AND IsDeleted <> 1);
                 
                 SET @AppAccessOldUserId=(SELECT TOP 1 UserId FROM dbo.[User] WHERE MobileNumber=@AppAccessOldMobileNo AND Uname=@AppAccessOldMobileNo);
                  IF  EXISTS(SELECT 1 FROM dbo.Student WHERE AppAccessMobileNo=@AppAccessOldMobileNo)
                  BEGIN
                    SET @IsDifferentUserRoleExist=1;
                  END
                UPDATE dbo.Student SET AppAccessOneTimePassword = @AppAccessOneTimePassword WHERE FirstName = @Student_First_Name AND MiddleName = @Student_Middle_Name AND
                                            LastName = @Student_Last_Name AND CONVERT (VARCHAR(100),BirthDate, 105) =CONVERT (VARCHAR(100),@BirthDate, 105) AND IsDeleted <> 1; 
                SELECT @RefId = StudentId FROM Student WHERE FirstName = @Student_First_Name AND MiddleName = @Student_Middle_Name AND
                                            LastName = @Student_Last_Name AND CONVERT (VARCHAR(100),BirthDate, 105) =CONVERT (VARCHAR(100),@BirthDate, 105) AND IsDeleted <> 1; 
                EXEC uspUserUpsert @Do_you_required_parent_mobile_app_access,@AppAccessOldUserId,@IsDifferentUserRoleExist,@Mobile_Number_for_Application_Access,@Upassword,@PasswordSalt,5,@UserId,@Student_First_Name,@Student_Last_Name,@RefId
            
            END
        
            -- Fetch next row into variables
        FETCH NEXT FROM student_cursor INTO @Student_First_Name, @Student_Middle_Name, @Student_Last_Name, @BirthDate,
        @Do_you_required_parent_mobile_app_access, @AppAccessOneTimePassword, @PasswordSalt, @Upassword,@Mobile_Number_for_Application_Access
        END

        -- Close the cursor
        CLOSE student_cursor
        -- Deallocate the cursor
        DEALLOCATE student_cursor
        -- end

     END TRY
    BEGIN CATCH
      -- Log the exception
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
                                 @ErrorState;
    END CATCH
	SELECT @InsertedCount AS InsertedCount, @UpdatedCount AS UpdatedCount;
  END
GO
