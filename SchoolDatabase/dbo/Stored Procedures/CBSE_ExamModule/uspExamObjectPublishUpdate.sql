-- =============================================
-- Author:   Saurabh Walunj
-- Create date: 14/08/2024
-- Description:  This stored procedure is used to Published & unpublished Exam Object data
-- =============================================
CREATE PROCEDURE uspExamObjectPublishUpdate
(
	@ExamObjectId SMALLINT,
	@IsPublished BIT,
	@UserId INT
)

AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 
	
DECLARE @CurrentDateTime DATETIME = GETDATE();
BEGIN TRY 

    UPDATE CBSE_ExamObject
	SET 
		IsPublished=@IsPublished,
		ModifiedBy = @UserId,
		ModifiedDate = @CurrentDateTime 

	WHERE ExamObjectId=@ExamObjectId
	AND IsDeleted<>1;

END TRY
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