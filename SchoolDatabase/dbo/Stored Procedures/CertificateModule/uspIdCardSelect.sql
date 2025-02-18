﻿-- =============================================
-- Author:   Shambala Apugade
-- Create date: 04/12/2023
-- Description:  This stored procedure is used to get Certifcate detail 
-- =============================================
CREATE PROC uspIdCardSelect(
	@AcademicYearId SMALLINT,
	@GradeId SMALLINT,
	@DivisionId SMALLINT,
	@StudentId SMALLINT
	)
AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 
	
SELECT 

s.schoolName,
a.AcademicYearName,
st.FirstName + ' ' + st.MiddleName + ' ' + st.LastName AS 'Name',
st.BirthDate,
st.BloodGroup,
st.CurrentAddressLine1 + ' ' +st.CurrentAddressLine2 + ' ' + st.CurrentTalukaName + ' ' + st.CurrentDistrictName + ' ' + st.CurrentStateName + ' ' + st.CurrentZipcode as 'Address',
st.EmergencyContactNumber,
g.GradeName,
d.DivisionName,
st.ProfileImageURL,
s.LogoUrl,
st.ProfileImageURL AS studentLogoUrl,
s.LogoUrl AS schoolLogoUrl

	FROM
	 StudentGradeDivisionMapping m 
	 INNER JOIN Student st ON m.studentId = st.StudentId
	 INNER JOIN Grade g ON m.GradeId = g.GradeId
	 INNER JOIN Division d ON m.DivisionId = d.DivisionId
	 INNER JOIN School s ON st.SchoolId = s.SchoolId
	 INNER JOIN AcademicYear a ON a.AcademicYearId = s.AcademicYearId

	 WHERE 
	  st.StudentId = ISNULL(@StudentId, st.StudentId)
	  AND g.GradeId = ISNULL(@GradeId, g.GradeId)
	  AND d.DivisionId =  ISNULL(@DivisionId, d.DivisionId)
	  AND m.IsDeleted <> 1
	  AND m.AcademicYearId = @AcademicYearId

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
