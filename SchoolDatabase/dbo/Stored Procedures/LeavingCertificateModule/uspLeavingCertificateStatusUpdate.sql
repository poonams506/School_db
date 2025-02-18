-- =============================================
-- Author:   Deepak W
-- Create date: 01/01/2024
-- Description:  This stored procedure is used to update Leaving Certifcates details
-- =============================================
CREATE PROCEDURE [dbo].[uspLeavingCertificateStatusUpdate]
(
    @LeavingCertificateAuditsId INT,
	@StudentId BIGINT,
	@StatusId INT,
	@UserId INT
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON DECLARE @CurrentDateTime DATETIME = GETDATE();
  BEGIN TRY 
    
   -- update status id in main table
   UPDATE LeavingCertificateAudits SET StatusId = @StatusId, ModifiedBy = @UserId, ModifiedDate = @CurrentDateTime
   WHERE LeavingCertificateAuditsId = @LeavingCertificateAuditsId AND StudentId = @StudentId AND IsDeleted <> 1;

   IF @StatusId = 2 OR @StatusId = 3
   BEGIN
     UPDATE Student SET IsArchive = 1, ModifiedBy = @UserId, ModifiedDate = @CurrentDateTime WHERE StudentId = @StudentId AND IsDeleted <> 1
   END

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