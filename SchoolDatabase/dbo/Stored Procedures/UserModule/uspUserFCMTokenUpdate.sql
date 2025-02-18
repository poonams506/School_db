CREATE PROCEDURE uspUserFCMTokenUpdate (
  @UserId INT,
  @FCMToken NVARCHAR(250)
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 

  NOCOUNT ON 
  DECLARE @CurrentDateTime DATETIME = GETDATE();
  

BEGIN TRY 

UPDATE dbo.[User] SET FCMToken=@FCMToken,ModifiedDate=@CurrentDateTime
	   WHERE UserId=@UserId;
  

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
@ErrorState END CATCH END
