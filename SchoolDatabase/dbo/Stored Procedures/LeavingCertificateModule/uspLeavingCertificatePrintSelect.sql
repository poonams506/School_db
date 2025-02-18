-- =============================================
-- Author:   Deepak W
-- Create date: 04/12/2023
-- Description:  This stored procedure is used to get Certifcate detail 
-- =============================================
CREATE PROC [dbo].[uspLeavingCertificatePrintSelect](
	@LeavingCertificateAuditsId INT,
	@StudentId INT
	)
AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 

SELECT 

s.SchoolName,
s.SchoolContactNo1,
s.SchoolEmail,
s.AffiliationNumber,
s.SchoolPermission,
s.RegistrationNumber,
s.UdiseNumber,
s.Section,
s.LogoUrl,
s.Board,
s.AuthorisedBy,
st.GeneralRegistrationNo,
st.CbscStudentId,
st.StudentId,
st.FirstName,
st.MiddleName, 
st.LastName,
st.AdharNo,
s.HscOrSscIndexNo,
mt.MediumTypeName,
(SELECT TOP 1 fp.FirstName FROM ParentStudentMapping fm INNER JOIN Parent fp ON fm.ParentId =fp.ParentId WHERE fm.StudentId = @StudentId AND fp.ParentTypeId = 12 and fp.IsDeleted <> 1) AS 'MotherName',
st.Nationality,
st.Religion,
st.BirthPlace,
st.BirthTalukaName,
st.BirthStateName,
st.BirthDistrictName,
st.BirthCountryName,
st.BirthDateInWords,
st.LastSchoolAttended,
st.LastSchoolStandard,
st.DateOfAdmission,
st.MotherTounge,
st.Cast,
st.BirthDate,
st.SubCast,
st.DateOfLeavingLastSchool,
g.GradeName AS 'GradeName',
st.GradeNameAdmission,
l.DateOfLeavingTheSchool AS DateOfLeavingSchoolCurrent,
l.DateSignCurrent AS DateSignCurrent,
l.Conduct AS ConductCurrent,
l.Progress AS ProgressCurrent,
l.StdInWhichStudyingAndSinceWhenInWordsAndFigures AS StandardInWhichStudyingCurrent,
l.ReasonOfLeavingSchool AS ReasonOfLeavingSchoolCurrent,
l.Remark AS RemarkCurrent,
l.SerialNumber,
l.LeavingCertificateAuditsId

	FROM
	 StudentGradeDivisionMapping m 
	 INNER JOIN Student st ON m.studentId = st.StudentId
	 INNER JOIN Grade g ON m.GradeId = g.GradeId
	 INNER JOIN Division d ON m.DivisionId = d.DivisionId
	 INNER JOIN School s ON st.SchoolId = s.SchoolId
	 INNER JOIN MediumType mt ON mt.MediumTypeId = s.SchoolMediumId
	 INNER JOIN LeavingCertificateAudits l ON l.LeavingCertificateAuditsId = @LeavingCertificateAuditsId AND l.StudentId = @StudentId
	 WHERE 
	  st.StudentId = ISNULL(@StudentId, st.StudentId)
	  AND m.IsDeleted <> 1

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



