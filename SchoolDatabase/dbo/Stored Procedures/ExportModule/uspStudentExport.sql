-- =============================================
-- Author:    Meena Kotakr
-- Create date: 26/02/2024
-- Description:  This stored procedure is used to export Student info detail 
-- =============================================
CREATE PROC [dbo].[uspStudentExport](@AcademicYearId SMALLINT) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 
        SELECT 
            
            st.FirstName,
            st.MiddleName, 
            st.LastName, 
            st.GeneralRegistrationNo, 
            st.AdmissionNo, 
            m.RollNumber,
            g.GradeName,
            d.DivisionName,
           	REPLACE(CONVERT(NVARCHAR(20), st.DateOfAdmission, 105), '-', '_')  AS DateOfAdmission,
            st.CbscStudentId,
            st.Gender, 
            st.AdharNo, 
            st.Religion, 
            st.Category, 
            st.Cast, 
            st.SubCast, 
            st.Nationality, 
            st.MotherTounge, 
            st.EmergencyContactPersonName, 
            st.EmergencyContactNumber, 
            st.FamilyDoctorName, 
            st.FamilyDoctorContactNumber, 
            st.BirthPlace, 
			REPLACE(CONVERT(NVARCHAR(20), st.BirthDate, 105), '-', '_') AS BirthDate ,
            st.BirthDateInWords, 
            st.BirthTalukaName, 
            st.BirthDistrictName,
            st.BirthStateName, 
            st.BirthCountryName,
            st.BloodGroup, 
            CONVERT(NVARCHAR(10),st.Height) AS Height, 
            CONVERT(NVARCHAR(10),st.Weight) AS Weight, 
            st.CurrentAddressLine1,
            st.CurrentAddressLine2, 
            st.CurrentTalukaName, 
            st.CurrentDistrictName, 
            st.CurrentStateName, 
            st.CurrentCountryName,
            st.CurrentZipcode,
            st.MedicalHistory, 
            st.LastSchoolAttended, 
            st.LastSchoolStandard, 
            st.LastSchoolDivision, 
            st.ProgressNoteFromLastSchool, 
            st.ConductNoteFromLastSchool, 
            st.StandardInWhichLastStudyingSection, 
            st.SinceWhenStudyingInLastSchool, 
            st.ReasonOfLeavingSchoolLastSchool,  
			REPLACE(CONVERT(NVARCHAR(20), st.DateOfLeavingLastSchool, 105), '-', '_') AS DateOfLeavingLastSchool ,
            st.RemarkFromLastSchool, 
            st.ProfileImageURL,
            REPLACE(a.AcademicYearName,'-', '_') AS AcademicYearName,
        	CASE  WHEN st.IsNewStudent=1 THEN 'Y'
			WHEN st.IsNewStudent=0 THEN 'N'END AS 'IsNewStudent',
			CASE  WHEN m.IsRTEStudent=1 THEN 'Y'
			WHEN m.IsRTEStudent=0 THEN 'N'END AS 'IsRTEStudent',
			CASE  WHEN m.IsConsationApplicable=1 THEN 'Y'
			WHEN m.IsConsationApplicable=0 THEN 'N'END AS 'IsConsationApplicable',
			CONVERT(NVARCHAR(10),m.ConsationAmount) AS ConsationAmount, 
            CONVERT(NVARCHAR(10),st.PreviousAcademicYearPendingFeeAmount) AS PreviousAcademicYearPendingFeeAmount, 
        	CASE  WHEN st.IsArchive=1 THEN 'Y'
			WHEN st.IsArchive=0 THEN 'N'END AS 'IsArchive',
            CASE  WHEN st.IsAppAccess=1 THEN 'Y'
			WHEN st.IsAppAccess=0 THEN 'N'END AS 'IsAppAccess',
            st.AppAccessMobileNo,
            st.AppAccessOneTimePassword,
			
            (SELECT fp.FirstName FROM ParentStudentMapping fm INNER JOIN Parent fp ON fm.ParentId =fp.ParentId WHERE fm.StudentId =st.StudentId AND fp.ParentTypeId = 11 AND fp.IsDeleted <> 1)  AS FatherFirstName,
            (SELECT fp.MiddleName FROM ParentStudentMapping fm INNER JOIN Parent fp ON fm.ParentId =fp.ParentId WHERE fm.StudentId =st.StudentId AND fp.ParentTypeId = 11 AND fp.IsDeleted <> 1) AS FatherMiddleName,
           (SELECT fp.LastName FROM ParentStudentMapping fm INNER JOIN Parent fp ON fm.ParentId =fp.ParentId WHERE fm.StudentId =st.StudentId AND fp.ParentTypeId = 11 AND fp.IsDeleted <> 1)AS FatherLastName,
			(SELECT fp.Gender FROM ParentStudentMapping fm INNER JOIN Parent fp ON fm.ParentId =fp.ParentId WHERE fm.StudentId =st.StudentId AND fp.ParentTypeId = 11 AND fp.IsDeleted <> 1) AS FatherGender,
			(SELECT fp.ContactNumber FROM ParentStudentMapping fm INNER JOIN Parent fp ON fm.ParentId =fp.ParentId WHERE fm.StudentId =st.StudentId AND fp.ParentTypeId = 11 AND fp.IsDeleted <> 1) AS FatherConactNo, 
			(SELECT fp.MobileNumber FROM ParentStudentMapping fm INNER JOIN Parent fp ON fm.ParentId =fp.ParentId WHERE fm.StudentId =st.StudentId AND fp.ParentTypeId = 11 AND fp.IsDeleted <> 1) AS FatherMobileNo, 
			(SELECT fp.EmailId FROM ParentStudentMapping fm INNER JOIN Parent fp ON fm.ParentId =fp.ParentId WHERE fm.StudentId =st.StudentId AND fp.ParentTypeId = 11 AND fp.IsDeleted <> 1)AS FatherEmailId, 
			(SELECT fp.AddressLine1 FROM ParentStudentMapping fm INNER JOIN Parent fp ON fm.ParentId =fp.ParentId WHERE fm.StudentId =st.StudentId AND fp.ParentTypeId = 11 AND fp.IsDeleted <> 1) AS FatherAddressLine1, 
			(SELECT fp.AddressLine2 FROM ParentStudentMapping fm INNER JOIN Parent fp ON fm.ParentId =fp.ParentId WHERE fm.StudentId =st.StudentId AND fp.ParentTypeId = 11 AND fp.IsDeleted <> 1) AS FatherAddressLine2, 
			(SELECT fp.TalukaName FROM ParentStudentMapping fm INNER JOIN Parent fp ON fm.ParentId =fp.ParentId WHERE fm.StudentId =st.StudentId AND fp.ParentTypeId = 11 AND fp.IsDeleted <> 1)AS FatherTalukaName, 
			 (SELECT fp.DistrictName FROM ParentStudentMapping fm INNER JOIN Parent fp ON fm.ParentId =fp.ParentId WHERE fm.StudentId =st.StudentId AND fp.ParentTypeId = 11 AND fp.IsDeleted <> 1) AS FatherDistrictName , 
			(SELECT fp.StateName FROM ParentStudentMapping fm INNER JOIN Parent fp ON fm.ParentId =fp.ParentId WHERE fm.StudentId =st.StudentId AND fp.ParentTypeId = 11 AND fp.IsDeleted <> 1)AS  FatherStateName, 
			  (SELECT fp.CountryName FROM ParentStudentMapping fm INNER JOIN Parent fp ON fm.ParentId =fp.ParentId WHERE fm.StudentId =st.StudentId AND fp.ParentTypeId = 11 AND fp.IsDeleted <> 1) AS FatherCountryName, 
			  (SELECT fp.Zipcode FROM ParentStudentMapping fm INNER JOIN Parent fp ON fm.ParentId =fp.ParentId WHERE fm.StudentId =st.StudentId AND fp.ParentTypeId = 11 AND fp.IsDeleted <> 1) AS FatherPincode , 
			  (SELECT fp.AdharNumber FROM ParentStudentMapping fm INNER JOIN Parent fp ON fm.ParentId =fp.ParentId WHERE fm.StudentId =st.StudentId AND fp.ParentTypeId = 11 AND fp.IsDeleted <> 1) AS FatherAdharNumber, 
			 (SELECT fp.Education FROM ParentStudentMapping fm INNER JOIN Parent fp ON fm.ParentId =fp.ParentId WHERE fm.StudentId =st.StudentId AND fp.ParentTypeId = 11 AND fp.IsDeleted <> 1) AS FatherEducation, 
			 REPLACE(CONVERT(NVARCHAR(20),(SELECT fp.BirthDate FROM ParentStudentMapping fm INNER JOIN Parent fp ON fm.ParentId =fp.ParentId WHERE fm.StudentId =st.StudentId AND fp.ParentTypeId = 11 AND fp.IsDeleted <> 1), 105), '-', '_') AS  FatherBirthDate , 
			 (SELECT fp.Occupation FROM ParentStudentMapping fm INNER JOIN Parent fp ON fm.ParentId =fp.ParentId WHERE fm.StudentId =st.StudentId AND fp.ParentTypeId = 11 AND fp.IsDeleted <> 1) AS FatherOccupation, 
			  CONVERT(NVARCHAR(10),(SELECT fp.AnnualIncome FROM ParentStudentMapping fm INNER JOIN Parent fp ON fm.ParentId =fp.ParentId WHERE fm.StudentId =st.StudentId AND fp.ParentTypeId = 11 AND fp.IsDeleted <> 1)) AS  FatherAnnualIncome, 
			(SELECT fp.BloodGroup FROM ParentStudentMapping fm INNER JOIN Parent fp ON fm.ParentId =fp.ParentId WHERE fm.StudentId =st.StudentId AND fp.ParentTypeId = 11 AND fp.IsDeleted <> 1) AS  FatherBloodGroup ,
				
            (SELECT mm.FirstName FROM ParentStudentMapping fm INNER JOIN Parent mm ON fm.ParentId =mm.ParentId WHERE fm.StudentId =st.StudentId AND mm.ParentTypeId = 12 AND mm.IsDeleted <> 1)  AS MotherFirstName,
            (SELECT mm.MiddleName FROM ParentStudentMapping fm INNER JOIN Parent mm ON fm.ParentId =mm.ParentId WHERE fm.StudentId =st.StudentId AND mm.ParentTypeId =12 AND mm.IsDeleted <> 1) AS MotherMiddleName,
           (SELECT mm.LastName FROM ParentStudentMapping fm INNER JOIN Parent mm ON fm.ParentId =mm.ParentId WHERE fm.StudentId =st.StudentId AND mm.ParentTypeId =12 AND mm.IsDeleted <> 1)AS MotherLastName,
			(SELECT mm.Gender FROM ParentStudentMapping fm INNER JOIN Parent mm ON fm.ParentId =mm.ParentId WHERE fm.StudentId =st.StudentId AND mm.ParentTypeId =12 AND mm.IsDeleted <> 1) AS MotherGender,
			(SELECT mm.ContactNumber FROM ParentStudentMapping fm INNER JOIN Parent mm ON fm.ParentId =mm.ParentId WHERE fm.StudentId =st.StudentId AND mm.ParentTypeId =12 AND mm.IsDeleted <> 1) AS MotherConactNo, 
			(SELECT mm.MobileNumber FROM ParentStudentMapping fm INNER JOIN Parent mm ON fm.ParentId =mm.ParentId WHERE fm.StudentId =st.StudentId AND mm.ParentTypeId =12 AND mm.IsDeleted <> 1) AS MotherMobileNo, 
			(SELECT mm.EmailId FROM ParentStudentMapping fm INNER JOIN Parent mm ON fm.ParentId =mm.ParentId WHERE fm.StudentId =st.StudentId AND mm.ParentTypeId =12 AND mm.IsDeleted <> 1)AS MotherEmailId, 
			(SELECT mm.AddressLine1 FROM ParentStudentMapping fm INNER JOIN Parent mm ON fm.ParentId =mm.ParentId WHERE fm.StudentId =st.StudentId AND mm.ParentTypeId =12 AND mm.IsDeleted <> 1) AS MotherAddressLine1, 
			(SELECT mm.AddressLine2 FROM ParentStudentMapping fm INNER JOIN Parent mm ON fm.ParentId =mm.ParentId WHERE fm.StudentId =st.StudentId AND mm.ParentTypeId =12 AND mm.IsDeleted <> 1) AS MotherAddressLine2, 
			(SELECT mm.TalukaName FROM ParentStudentMapping fm INNER JOIN Parent mm ON fm.ParentId =mm.ParentId WHERE fm.StudentId =st.StudentId AND mm.ParentTypeId =12 AND mm.IsDeleted <> 1)AS MotherTalukaName, 
			 (SELECT mm.DistrictName FROM ParentStudentMapping fm INNER JOIN Parent mm ON fm.ParentId =mm.ParentId WHERE fm.StudentId =st.StudentId AND mm.ParentTypeId =12 AND mm.IsDeleted <> 1) AS MotherDistrictName , 
			(SELECT mm.StateName FROM ParentStudentMapping fm INNER JOIN Parent mm ON fm.ParentId =mm.ParentId WHERE fm.StudentId =st.StudentId AND mm.ParentTypeId =12 AND mm.IsDeleted <> 1)AS  MotherStateName, 
			  (SELECT mm.CountryName FROM ParentStudentMapping fm INNER JOIN Parent mm ON fm.ParentId =mm.ParentId WHERE fm.StudentId =st.StudentId AND mm.ParentTypeId =12 AND mm.IsDeleted <> 1) AS MotherCountryName, 
			  (SELECT mm.Zipcode FROM ParentStudentMapping fm INNER JOIN Parent mm ON fm.ParentId =mm.ParentId WHERE fm.StudentId =st.StudentId AND mm.ParentTypeId =12 AND mm.IsDeleted <> 1) AS MotherPincode , 
			  (SELECT mm.AdharNumber FROM ParentStudentMapping fm INNER JOIN Parent mm ON fm.ParentId =mm.ParentId WHERE fm.StudentId =st.StudentId AND mm.ParentTypeId =12 AND mm.IsDeleted <> 1) AS MotherAdharNumber, 
			 (SELECT mm.Education FROM ParentStudentMapping fm INNER JOIN Parent mm ON fm.ParentId =mm.ParentId WHERE fm.StudentId =st.StudentId AND mm.ParentTypeId =12 AND mm.IsDeleted <> 1) AS MotherEducation, 
			 REPLACE(CONVERT(NVARCHAR(20),(SELECT mm.BirthDate FROM ParentStudentMapping fm INNER JOIN Parent mm ON fm.ParentId =mm.ParentId WHERE fm.StudentId =st.StudentId AND mm.ParentTypeId =12 AND mm.IsDeleted <> 1), 105), '-', '_') AS  MotherBirthDate , 
			 (SELECT mm.Occupation FROM ParentStudentMapping fm INNER JOIN Parent mm ON fm.ParentId =mm.ParentId WHERE fm.StudentId =st.StudentId AND mm.ParentTypeId =12 AND mm.IsDeleted <> 1) AS MotherOccupation, 
			 CONVERT(NVARCHAR(10), (SELECT mm.AnnualIncome FROM ParentStudentMapping fm INNER JOIN Parent mm ON fm.ParentId =mm.ParentId WHERE fm.StudentId =st.StudentId AND mm.ParentTypeId =12 AND mm.IsDeleted <> 1) )AS  MotherAnnualIncome, 
			(SELECT mm.BloodGroup FROM ParentStudentMapping fm INNER JOIN Parent mm ON fm.ParentId =mm.ParentId WHERE fm.StudentId =st.StudentId AND mm.ParentTypeId =12 AND mm.IsDeleted <> 1) AS  MotherBloodGroup ,
				
         
			
         			
             (SELECT fg.FirstName FROM ParentStudentMapping fm INNER JOIN Parent fg ON fm.ParentId =fg.ParentId WHERE fm.StudentId =st.StudentId AND fg.ParentTypeId = 13 AND fg.IsDeleted <> 1)  AS GuardianFirstName,
            (SELECT fg.MiddleName FROM ParentStudentMapping fm INNER JOIN Parent fg ON fm.ParentId =fg.ParentId WHERE fm.StudentId =st.StudentId AND fg.ParentTypeId =13 AND fg.IsDeleted <> 1) AS GuardianMiddleName,
           (SELECT fg.LastName FROM ParentStudentMapping fm INNER JOIN Parent fg ON fm.ParentId =fg.ParentId WHERE fm.StudentId =st.StudentId AND fg.ParentTypeId =13 AND fg.IsDeleted <> 1)AS GuardianLastName,
			(SELECT fg.Gender FROM ParentStudentMapping fm INNER JOIN Parent fg ON fm.ParentId =fg.ParentId WHERE fm.StudentId =st.StudentId AND fg.ParentTypeId =13 AND fg.IsDeleted <> 1) AS GuardianGender,
			(SELECT fg.ContactNumber FROM ParentStudentMapping fm INNER JOIN Parent fg ON fm.ParentId =fg.ParentId WHERE fm.StudentId =st.StudentId AND fg.ParentTypeId =13 AND fg.IsDeleted <> 1) AS GuardianConactNo, 
			(SELECT fg.MobileNumber FROM ParentStudentMapping fm INNER JOIN Parent fg ON fm.ParentId =fg.ParentId WHERE fm.StudentId =st.StudentId AND fg.ParentTypeId =13 AND fg.IsDeleted <> 1) AS GuardianMobileNo, 
			(SELECT fg.EmailId FROM ParentStudentMapping fm INNER JOIN Parent fg ON fm.ParentId =fg.ParentId WHERE fm.StudentId =st.StudentId AND fg.ParentTypeId =13 AND fg.IsDeleted <> 1)AS GuardianEmailId, 
			(SELECT fg.AddressLine1 FROM ParentStudentMapping fm INNER JOIN Parent fg ON fm.ParentId =fg.ParentId WHERE fm.StudentId =st.StudentId AND fg.ParentTypeId =13 AND fg.IsDeleted <> 1) AS GuardianAddressLine1, 
			(SELECT fg.AddressLine2 FROM ParentStudentMapping fm INNER JOIN Parent fg ON fm.ParentId =fg.ParentId WHERE fm.StudentId =st.StudentId AND fg.ParentTypeId =13 AND fg.IsDeleted <> 1) AS GuardianAddressLine2, 
			(SELECT fg.TalukaName FROM ParentStudentMapping fm INNER JOIN Parent fg ON fm.ParentId =fg.ParentId WHERE fm.StudentId =st.StudentId AND fg.ParentTypeId =13 AND fg.IsDeleted <> 1)AS GuardianTalukaName, 
			 (SELECT fg.DistrictName FROM ParentStudentMapping fm INNER JOIN Parent fg ON fm.ParentId =fg.ParentId WHERE fm.StudentId =st.StudentId AND fg.ParentTypeId =13 AND fg.IsDeleted <> 1) AS GuardianDistrictName , 
			(SELECT fg.StateName FROM ParentStudentMapping fm INNER JOIN Parent fg ON fm.ParentId =fg.ParentId WHERE fm.StudentId =st.StudentId AND fg.ParentTypeId =13 AND fg.IsDeleted <> 1)AS  GuardianStateName, 
			  (SELECT fg.CountryName FROM ParentStudentMapping fm INNER JOIN Parent fg ON fm.ParentId =fg.ParentId WHERE fm.StudentId =st.StudentId AND fg.ParentTypeId =13 AND fg.IsDeleted <> 1) AS GuardianCountryName, 
			  (SELECT fg.Zipcode FROM ParentStudentMapping fm INNER JOIN Parent fg ON fm.ParentId =fg.ParentId WHERE fm.StudentId =st.StudentId AND fg.ParentTypeId =13 AND fg.IsDeleted <> 1) AS GuardianPincode , 
			  (SELECT fg.AdharNumber FROM ParentStudentMapping fm INNER JOIN Parent fg ON fm.ParentId =fg.ParentId WHERE fm.StudentId =st.StudentId AND fg.ParentTypeId =13 AND fg.IsDeleted <> 1) AS GuardianAdharNumber, 
			 (SELECT fg.Education FROM ParentStudentMapping fm INNER JOIN Parent fg ON fm.ParentId =fg.ParentId WHERE fm.StudentId =st.StudentId AND fg.ParentTypeId =13 AND fg.IsDeleted <> 1) AS GuardianEducation, 
			 REPLACE(CONVERT(NVARCHAR(20),(SELECT fg.BirthDate FROM ParentStudentMapping fm INNER JOIN Parent fg ON fm.ParentId =fg.ParentId WHERE fm.StudentId =st.StudentId AND fg.ParentTypeId =13 AND fg.IsDeleted <> 1) , 105), '-', '_')AS  GuardianBirthDate , 
			 (SELECT fg.Occupation FROM ParentStudentMapping fm INNER JOIN Parent fg ON fm.ParentId =fg.ParentId WHERE fm.StudentId =st.StudentId AND fg.ParentTypeId =13 AND fg.IsDeleted <> 1) AS GuardianOccupation, 
			  CONVERT(NVARCHAR(10),(SELECT fg.AnnualIncome FROM ParentStudentMapping fm INNER JOIN Parent fg ON fm.ParentId =fg.ParentId WHERE fm.StudentId =st.StudentId AND fg.ParentTypeId =13 AND fg.IsDeleted <> 1)) AS  GuardianAnnualIncome, 
			(SELECT fg.BloodGroup FROM ParentStudentMapping fm INNER JOIN Parent fg ON fm.ParentId =fg.ParentId WHERE fm.StudentId =st.StudentId AND fg.ParentTypeId =13 AND fg.IsDeleted <> 1) AS  GuardianBloodGroup         
			 
       FROM 
            Student st
            INNER JOIN StudentGradeDivisionMapping m ON st.StudentId = m.StudentId AND m.AcademicYearId = @AcademicYearId
			INNER JOIN Grade g ON m.GradeId=g.GradeId
			INNER JOIN Division d ON m.DivisionId=d.DivisionId
			INNER JOIN AcademicYear a ON a.AcademicYearId=m.AcademicYearId
         	
        WHERE  
            st.IsDeleted <> 1 and st.IsArchive <> 1 and m.IsDeleted <> 1
			ORDER BY g.GradeName ASC,d.DivisionName ASC,m.RollNumber ASC;
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
END
