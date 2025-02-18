-- =============================================
-- Author:    Meena Kotkar
-- Create date: 26/05/2024
-- Description:  This stored procedure is used insert student profile
-- =============================================
CREATE PROCEDURE [dbo].[uspUpdatePreviousAcademicAYPendingFee] (
  @StudentId BIGINT, 
  @PreviousAcademicYearPendingFeeAmount MONEY,
  @UserId INT
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON DECLARE @CurrentDateTime DATETIME = GETDATE();
BEGIN TRY 
UPDATE 
  dbo.Student 
SET 
 [PreviousAcademicYearPendingFeeAmount]=@PreviousAcademicYearPendingFeeAmount,
  [ModifiedBy] = @UserId, 
  [ModifiedDate] = @CurrentDateTime
WHERE 
  StudentId = @StudentId 
	
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
