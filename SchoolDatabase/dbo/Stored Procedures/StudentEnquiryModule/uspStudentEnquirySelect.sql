--===============================================
-- Author:- Gulave Pramod 
-- Create date:- 06-08-2024
-- Description:- This stored procedure is used to get StudentEnquiryForm by Select.
-- =============================================
CREATE PROCEDURE [dbo].[uspStudentEnquirySelect]  (
	@StudentEnquiryId INT
)
AS 
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON; 
    BEGIN TRY 
SELECT
	s.StudentEnquiryId,
	s.EnquiryDate,
	s.StudentFirstName,
	s.StudentMiddleName,
	s.StudentLastName,
	s.Gender,
	s.BirthDate,
	s.AdharNo,
	s.Religion,
	s.Cast,
	s.Category,
	s.Nationality,
	s.MobileNumber,
	s.InterestedClassId,
	g.GradeName,
    di.DivisionName,
	s.AcademicYearId,
	s.CurrentSchool,
	s.CurrentClass,
	s.NameOfSiblingInCurrentSchool,
	s.FatherFirstName,
	s.FatherMiddleName,
	s.FatherLastName,
	s.MotherFirstName,
	s.MotherMiddleName,
	s.MotherLastName,
	s.AddressLine1,
	s.AddressLine2,
	c.CountryId,
	c.CountryName,
	st.StateId,
	st.StateName,
	t.TalukaId,
	t.TalukaName,
	d.DistrictId,
	d.Districtname,
	s.EmailId,
	s.ReferenceBy
FROM
	StudentEnquiry AS s 
	LEFT JOIN Country AS c on s.CountryId = c.CountryId
	LEFT JOIN State AS st on s.StateId = st.StateId
	LEFT JOIN Taluka AS t on s.TalukaId = t.TalukaId
	LEFT JOIN District AS d on s.DistrictId = d.DistrictId
	LEFT JOIN SchoolGradeDivisionMatrix sgm ON s.InterestedClassId=sgm.SchoolGradeDivisionMatrixId
    LEFT JOIN Grade AS g ON sgm.GradeId = g.GradeId
    LEFT JOIN Division AS di ON sgm.DivisionId  = di.DivisionId
WHERE
	s.StudentEnquiryId = @StudentEnquiryId
	AND s.IsDeleted <> 1	
  
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