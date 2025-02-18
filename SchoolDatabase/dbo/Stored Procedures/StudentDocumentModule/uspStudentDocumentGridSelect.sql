-- =============================================
-- Author:    Meena Kotkar
-- Create date: 21/09/2023
-- Description:  This stored procedure is used to get Document info detail by Id
-- =============================================
CREATE PROC [uspStudentDocumentGridSelect]
(
	@StudentId BIGINT = Null
)
AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 
SELECT
	DocumentId,
	DocumentName,
	DocumentUrl,
	DocumentFileType,
	CreatedDate AS UploadedDate
FROM 
  StudentDocuments 
WHERE 
	 StudentId = ISNULL(@StudentId, StudentId) AND IsDeleted <> 1 END TRY BEGIN CATCH DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
DECLARE @ErrorState INT = ERROR_STATE();
DECLARE @ErrorNumber INT = ERROR_NUMBER();
DECLARE @ErrorLine INT = ERROR_PROCEDURE();
DECLARE @ErrorProcedure NVARCHAR(1000) = ERROR_LINE();
EXEC uspExceptionLogInsert @ErrorLine, 
@ErrorMessage, 
@ErrorNumber, 
@ErrorProcedure, 
@ErrorSeverity, 
@ErrorState END CATCH End