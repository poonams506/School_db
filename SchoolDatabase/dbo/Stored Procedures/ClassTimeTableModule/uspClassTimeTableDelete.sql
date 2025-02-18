
-- =============================================
-- Author: Abhishek Kumar
-- Create date: 02/01/2023
-- Description: This stored procedure is used for deleting Class Timetable Upsert
-- =============================================
CREATE PROCEDURE [dbo].[uspClassTimeTableDelete]
	@classTimeTableId INT,
	@UserId INT
AS BEGIN 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON
DECLARE @CurrentDateTime DATETIME = GETDATE();

BEGIN TRY 

BEGIN TRAN;

  UPDATE dbo.ClassTimeTable 
  SET 
	IsDeleted=1,
	ModifiedBy=@UserId,
    ModifiedDate=@CurrentDateTime
  WHERE ClassTimeTableId=@classTimeTableId and ISNULL(isActive,0)<>1;


  COMMIT;
  return @@ROWCOUNT;

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
@ErrorState END CATCH END