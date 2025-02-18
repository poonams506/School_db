-- =============================================
-- Author:    Deepak Walunj
-- Create date: 18/09/2023
-- Description:  This stored procedure is used to update cheque status
-- =============================================
CREATE PROCEDURE [dbo].[uspStudentKitFeePaymentChequeClear]
@StudentKitFeePaymentId BIGINT,
@UserId INT
AS BEGIN
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 
        
    UPDATE StudentKitFeePayment SET IsChequeClear = 1, ModifiedBy = @UserId, ModifiedDate = GetDate() WHERE StudentKitFeePaymentId = @StudentKitFeePaymentId     
    UPDATE StudentKitFeePaymentDetails SET IsChequeClear = 1, ModifiedBy = @UserId, ModifiedDate = GetDate() WHERE StudentKitFeePaymentId = @StudentKitFeePaymentId     

		
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