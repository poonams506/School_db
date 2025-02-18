-- =============================================
-- Author:   Deepak W
-- Create date: 08/01/2024
-- Description:  This stored procedure is used to get Leaving Certifcate history detail by student Id
-- =============================================
CREATE PROC uspLeavingCertificateHistory(
	@StudentId INT
)
AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 
	SELECT 
	  c.LeavingCertificateAuditsId,
	  c.StatusId,
	  c.SerialNumber,
	  s.FirstName + ' ' + s.MiddleName + ' ' + s.LastName AS StudentName,
	  c.CreatedDate,
	  s.GeneralRegistrationNo
	FROM
	  LeavingCertificateAudits c
	  INNER JOIN Student s 
	  ON c.StudentId = s.StudentId
	WHERE 
	  c.StudentId = @StudentId
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
