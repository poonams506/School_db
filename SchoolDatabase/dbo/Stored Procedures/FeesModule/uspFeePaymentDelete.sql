-- =============================================
-- Author:    Deepak Walunj
-- Create date: 18/09/2023
-- Description:  This stored procedure is used to delete fee payment
-- =============================================
CREATE PROCEDURE [dbo].[uspFeePaymentDelete]
@FeePaymentId BIGINT,
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
    DECLARE @appliedDiscFeePaymentCount INT;
    DECLARE @appliedAdditionalDiscFeePaymentCount INT;
    SET @StudentId = (SELECT TOP 1 StudentId FROM FeePayment WHERE IsDeleted <> 1 AND FeePaymentId = @FeePaymentId);
    SET @AcademicYearId = (SELECT TOP 1 AcademicYearId FROM FeePayment WHERE IsDeleted <> 1 AND FeePaymentId = @FeePaymentId);
    IF EXISTS (SELECT FeePaymentAppliedWavierMappingId FROM FeePaymentAppliedWavierMapping WHERE StudentId = @StudentId AND AcademicYearId = @AcademicYearId AND FeePaymentId = @FeePaymentId AND IsDeleted <> 1)
    BEGIN
        SET @appliedDiscFeePaymentCount = (SELECT COUNT(FeePaymentId) FROM FeePayment WHERE StudentId = @StudentId AND AcademicYearId = @AcademicYearId AND IsDeleted <> 1  AND FeePaymentId > @FeePaymentId)
    END
    IF EXISTS (SELECT FeeAdditionalDiscountId FROM FeeAdditionalDiscount WHERE StudentId = @StudentId AND AcademicYearId = @AcademicYearId AND FeePaymentId = @FeePaymentId AND IsDeleted <> 1)
    BEGIN
        SET @appliedAdditionalDiscFeePaymentCount = (SELECT COUNT(FeePaymentId) FROM FeePayment WHERE StudentId = @StudentId AND AcademicYearId = @AcademicYearId AND IsDeleted <> 1 AND FeePaymentId > @FeePaymentId)
    END


    IF @appliedDiscFeePaymentCount > 0 OR @appliedAdditionalDiscFeePaymentCount > 0
    BEGIN
        SET @YouCanDelete = 0;
    END

    IF @YouCanDelete = 1
    BEGIN
        UPDATE FeePayment SET IsDeleted = 1,ModifiedBy = @UserId, ModifiedDate = GetDate() WHERE FeePaymentId = @FeePaymentId     
        UPDATE FeePaymentDetails SET IsDeleted = 1,ModifiedBy = @UserId, ModifiedDate = GetDate() WHERE FeePaymentId = @FeePaymentId
        UPDATE FeeAdditionalDiscount SET IsDeleted = 1,ModifiedBy = @UserId, ModifiedDate = GetDate() WHERE FeePaymentId = @FeePaymentId
        UPDATE FeePaymentAppliedWavierMapping SET IsDeleted = 1,ModifiedBy = @UserId, ModifiedDate = GetDate() WHERE FeePaymentId = @FeePaymentId
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