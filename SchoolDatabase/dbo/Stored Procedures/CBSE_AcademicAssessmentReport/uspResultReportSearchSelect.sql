--===============================================
-- Author:    Prerana Aher
-- Create date: 28/10/2024  
-- Description:  This stored procedure is used to get result report  
-- =============================================
CREATE PROC [dbo].[uspResultReportSearchSelect](
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
	  s.SchoolName,
	  s.SchoolContactNo1,
	  s.SchoolEmail,
	  s.AffiliationNumber,
	  s.SchoolPermission,
	  s.RegistrationNumber,
	  s.Section,
	  s.SchoolType,
	  s.LogoUrl,
	  mt.MediumTypeName,
	  CONCAT (st.FirstName , ' ' , st.MiddleName , ' ' , st.LastName) AS 'StudentName',
	  d.DivisionName,
	  g.GradeName,
	  st.MotherTounge,
	  st.BirthDate,
	  st.EmergencyContactNumber,
	  st.Weight,
	  st.Height,
	  st.BloodGroup,
	  st.Gender,
	  ISNULL(st.CurrentAddressLine1,'') + IIF(st.CurrentAddressLine1 IS NULL,'',', ') + ISNULL(st.CurrentAddressLine2,'') + IIF(st.CurrentAddressLine2 IS NULL,'',', ') + st.CurrentTalukaName + ', ' + st.CurrentDistrictName + IIF(st.CurrentZipcode IS NULL,'',', ' + st.CurrentZipcode) AS 'CurrentAddressLine1',

	  st.EmergencyContactNumber as 'ContactNo',
	  st.GeneralRegistrationNo ,
	  m.RollNumber as 'RollNo',
	   (SELECT fp.FirstName+' '+fp.MiddleName+' '+fp.LastName  FROM ParentStudentMapping fm INNER JOIN Parent fp ON fm.ParentId =fp.ParentId WHERE fm.StudentId = st.StudentId AND fp.ParentTypeId = 11 and fp.IsDeleted <> 1) AS 'FatherName'
  , (SELECT  fp.FirstName+' '+fp.MiddleName+' '+fp.LastName  FROM ParentStudentMapping fm INNER JOIN Parent fp ON fm.ParentId =fp.ParentId WHERE fm.StudentId = st.StudentId AND fp.ParentTypeId = 12 and fp.IsDeleted <> 1) AS 'MotherName'
    , (SELECT  fp.Occupation  FROM ParentStudentMapping fm INNER JOIN Parent fp ON fm.ParentId =fp.ParentId WHERE fm.StudentId = st.StudentId AND fp.ParentTypeId = 11 and fp.IsDeleted <> 1) AS 'FatherOccupation'
  , (SELECT  fp.Occupation  FROM ParentStudentMapping fm INNER JOIN Parent fp ON fm.ParentId =fp.ParentId WHERE fm.StudentId = st.StudentId AND fp.ParentTypeId = 12 and fp.IsDeleted <> 1) AS 'MotherOccupation'


	FROM
	 StudentGradeDivisionMapping m 
	 INNER JOIN Student st ON m.studentId = st.StudentId
	 INNER JOIN Grade g ON m.GradeId = g.GradeId
	 INNER JOIN Division d ON m.DivisionId = d.DivisionId
	 INNER JOIN School s ON st.SchoolId = s.SchoolId
	 INNER JOIN MediumType mt ON mt.MediumTypeId = s.SchoolMediumId
	 INNER JOIN AcademicYear a ON a.AcademicYearId = s.AcademicYearId

	 WHERE 
	  st.StudentId = ISNULL(@StudentId, st.StudentId)
	  AND g.GradeId = ISNULL(@GradeId, g.GradeId)
	  AND d.DivisionId =  ISNULL(@DivisionId, d.DivisionId)
	  AND m.IsDeleted <> 1 AND s.IsDeleted <> 1
	  AND m.AcademicYearId = @AcademicYearId
	  AND a.AcademicYearId = @AcademicYearId
	  AND s.AcademicYearId=@AcademicYearId

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