-- =============================================
-- Author:    Abhishek Kumar
-- Create date: 17/02/2024
-- Description:  This stored procedure is used to get School Detail for Mobile App.
-- =============================================
CREATE PROCEDURE uspSchoolAppDetailSelect
AS BEGIN
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 

    SELECT  sc.SchoolId,sc.SchoolName,sc.LogoUrl, sc.AcademicYearId, st.AcademicYearStartMonth
	FROM dbo.School sc
	INNER JOIN dbo.SchoolSetting st
	ON sc.AcademicYearId = st.AcademicYearId
	AND st.IsDeleted <> 1;

 END 
 TRY 
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

