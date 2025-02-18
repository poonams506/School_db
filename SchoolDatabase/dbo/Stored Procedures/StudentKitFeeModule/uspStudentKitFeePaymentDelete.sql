-- =============================================
-- Author:    Deepak Walunj
-- Create date: 18/09/2023
-- Description:  This stored procedure is used to delete fee payment
-- =============================================
CREATE PROCEDURE [dbo].[uspStudentKitFeePaymentDelete]
@StudentKitFeePaymentId BIGINT,
@UserId INT
AS BEGIN
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 
    BEGIN TRANSACTION
    DECLARE @StudentId BIGINT,
            @AcademicYearId SMALLINT,
            @YouCanDelete INT;
    SET @YouCanDelete = 1;
    DECLARE @appliedAdditionalDiscFeePaymentCount INT;
    SET @StudentId = (SELECT TOP 1 StudentId FROM StudentKitFeePayment WHERE IsDeleted <> 1 AND StudentKitFeePaymentId = @StudentKitFeePaymentId);
    SET @AcademicYearId = (SELECT TOP 1 AcademicYearId FROM StudentKitFeePayment WHERE IsDeleted <> 1 AND StudentKitFeePaymentId = @StudentKitFeePaymentId);
   
    IF EXISTS (SELECT StudentKitFeeAdditionalDiscountId FROM StudentKitFeeAdditionalDiscount WHERE StudentId = @StudentId AND AcademicYearId = @AcademicYearId AND StudentKitFeePaymentId = @StudentKitFeePaymentId AND IsDeleted <> 1)
    BEGIN
        SET @appliedAdditionalDiscFeePaymentCount = (SELECT COUNT(StudentKitFeePaymentId) FROM StudentKitFeePayment WHERE StudentId = @StudentId AND AcademicYearId = @AcademicYearId AND IsDeleted <> 1 AND StudentKitFeePaymentId > @StudentKitFeePaymentId)
    END


    IF @appliedAdditionalDiscFeePaymentCount > 0
    BEGIN
        SET @YouCanDelete = 0;
    END

    IF @YouCanDelete = 1
    BEGIN
        UPDATE StudentKitFeePayment SET IsDeleted = 1,ModifiedBy = @UserId, ModifiedDate = GetDate() WHERE StudentKitFeePaymentId = @StudentKitFeePaymentId     
        UPDATE StudentKitFeePaymentDetails SET IsDeleted = 1,ModifiedBy = @UserId, ModifiedDate = GetDate() WHERE StudentKitFeePaymentId = @StudentKitFeePaymentId
        UPDATE StudentKitFeeAdditionalDiscount SET IsDeleted = 1,ModifiedBy = @UserId, ModifiedDate = GetDate() WHERE StudentKitFeePaymentId = @StudentKitFeePaymentId
    END

    SELECT @YouCanDelete
COMMIT TRANSACTION
END TRY 
BEGIN CATCH 
ROLLBACK TRANSACTION
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
@ErrorState END CATCH End