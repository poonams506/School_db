-- =============================================
-- Author:    Swapnil Bhaskar
-- Create date: 07/08/2023
-- Description:  This stored procedure is used to get Student info detail by Id
-- =============================================
CREATE PROC [dbo].[uspStudentSelect](@StudentId BIGINT = NULL, @AcademicYearId SMALLINT) AS Begin 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 
SELECT 
  st.StudentId,
  st.GeneralRegistrationNo, 
  st.CbscStudentId,
  st.AdmissionNo, 
  st.SchoolId, 
  st.FirstName, 
  st.MiddleName, 
  st.LastName, 
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
  st.BirthDate, 
  st.BirthDateInWords, 
  st.BirthCountryId, 
  st.BirthStateId, 
  st.BirthDistrictId, 
  st.BirthTalukaId, 
  st.BirthTalukaName, 
  st.BirthDistrictName,
  st.BirthStateName, 
  st.BirthCountryName,
  st.BloodGroup, 
  st.Height, 
  st.Weight, 
  st.CurrentAddressLine1,
  st.CurrentAddressLine2, 
  st.CurrentTalukaId, 
  st.CurrentDistrictId, 
  st.CurrentStateId ,
  st.CurrentCountryId,
  st.CurrentTalukaName, 
  st.CurrentDistrictName, 
  st.CurrentStateName, 
  st.CurrentCountryName,
  st.CurrentZipcode,
  st.MedicalHistory, 
  st.AdmissionGrade, 
  st.DateOfAdmission, 
  st.LastSchoolAttended, 
  st.LastSchoolStandard, 
  st.LastSchoolDivision, 
  st.ProgressNoteFromLastSchool, 
  st.ConductNoteFromLastSchool, 
  st.StandardInWhichLastStudyingSection, 
  st.SinceWhenStudyingInLastSchool, 
  st.ReasonOfLeavingSchoolLastSchool, 
  st.DateOfLeavingLastSchool, 
  st.RemarkFromLastSchool, 
  st.ProfileImageURL,
  st.GradeNameAdmission,
  m.AcademicYearId,
  m.GradeId,
  m.DivisionId,
  m.RollNumber,
  st.IsNewStudent, 
  m.IsRTEStudent, 
  m.IsConsationApplicable, 
  m.ConsationAmount, 
  st.PreviousAcademicYearPendingFeeAmount,
  st.IsArchive,
  st.IsAppAccess,
  st.AppAccessMobileNo,
  st.AppAccessOneTimePassword
  , (SELECT fm.ParentId FROM ParentStudentMapping fm INNER JOIN Parent fp ON fm.ParentId =fp.ParentId WHERE fm.StudentId = @StudentId AND fp.ParentTypeId = 11 AND fp.IsDeleted <> 1) AS 'FatherId'
  , (SELECT fm.ParentId FROM ParentStudentMapping fm INNER JOIN Parent fp ON fm.ParentId =fp.ParentId WHERE fm.StudentId = @StudentId AND fp.ParentTypeId = 12 AND fp.IsDeleted <> 1) AS 'MotherId'
  , (SELECT fm.ParentId FROM ParentStudentMapping fm INNER JOIN Parent fp ON fm.ParentId =fp.ParentId WHERE fm.StudentId = @StudentId AND fp.ParentTypeId = 13 AND fp.IsDeleted <> 1) AS 'GuardianId'

From 
  Student st
  INNER JOIN StudentGradeDivisionMapping m ON
  st.StudentId = m.StudentId AND m.AcademicYearId = @AcademicYearId
WHERE 
 st.StudentId = ISNULL(@StudentId, st.StudentId)
 AND st.IsDeleted <> 1 AND st.IsArchive <> 1
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