-- =============================================
-- Author:   Meena Kotkar
-- Create date: 29/08/2023
-- Description:  This stored procedure is used to get Certifcate info detail by Id
-- =============================================
CREATE PROC uspCertificateSelect(
	@CertificateAuditsId BIGINT = NULL,
	@AcademicYearId SMALLINT)
AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 
	SELECT 
	  c.CertificateAuditsId,
	  c.CertificateTemplateId,
	  c.StudentId,
	  c.GradeId ,
	  c.DivisionId,
	  c.AcademicYearId,
	    CASE WHEN c.IsPublished = 1 THEN 'Y'
          WHEN c.IsPublished = 0 THEN 'N'
          END AS 'Status'
	FROM
	  CertificateAudits c
	  INNER JOIN StudentGradeDivisionMapping m ON c.StudentId = m.StudentId 
	WHERE 
	 c.CertificateAuditsId = ISNULL(@CertificateAuditsId, c.CertificateAuditsId)
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
