-- =============================================
-- Author:   Shambala Apugade
-- Create date: 04/12/2023
-- Description:  This stored procedure is used to get Certifcate detail 
-- =============================================
CREATE PROC [dbo].[uspCharcterCertificateSelect](
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
    st.StudentId,
    CONCAT(st.FirstName, ' ', COALESCE(st.MiddleName + ' ', ''), st.LastName) AS 'StudentName',
    st.Gender,
    CONCAT(p.FirstName, ' ', p.LastName) AS 'ParentName',
    CONCAT(s.SchoolAddressLine1, ' ', COALESCE(s.SchoolAddressLine2, ''), ' ', COALESCE(s.TalukaName, '')) AS 'Place',
    CONCAT(
        FLOOR(DATEDIFF(DAY, st.DateOfAdmission, GETDATE()) / 365), ' years, ',
        FLOOR((DATEDIFF(DAY, st.DateOfAdmission, GETDATE()) % 365) / 30), ' months')
        --DATEDIFF(DAY, DATEADD(MONTH, FLOOR(DATEDIFF(DAY, st.DateOfAdmission, GETDATE()) / 30), st.DateOfAdmission), GETDATE()) % 30, ' days' )
       AS 'TotalDayCount',
	CONCAT_WS(', ', st.CurrentAddressLine1, st.CurrentAddressLine2, st.CurrentTalukaName, st.CurrentDistrictName) AS 'StudentAddress'


	FROM
	 StudentGradeDivisionMapping m 
	 INNER JOIN Student st ON m.studentId = st.StudentId
	 INNER JOIN Grade g ON m.GradeId = g.GradeId
	 INNER JOIN Division d ON m.DivisionId = d.DivisionId
	 INNER JOIN School s ON st.SchoolId = s.SchoolId
	 INNER JOIN ParentStudentMapping pm ON  st.StudentId = pm.StudentId
     INNER JOIN Parent p ON  pm.ParentId = p.ParentId
	 
	 WHERE 
	  st.StudentId = ISNULL(@StudentId, st.StudentId)
	  AND g.GradeId = ISNULL(@GradeId, g.GradeId)
	  AND d.DivisionId =  ISNULL(@DivisionId, d.DivisionId)
	  AND m.IsDeleted <> 1 AND p.IsDeleted <> 1
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



