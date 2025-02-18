-- =============================================
-- Author:    Deepak Walunj
-- Create date: 18/09/2023
-- Description:  This stored procedure is used to delete fee payment
-- =============================================
CREATE PROCEDURE [dbo].[uspTransportFeePaymentDelete]
@TransportFeePaymentId BIGINT,
@UserId INT
AS BEGIN
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 
    BEGIN TRANSACTION
    DECLARE @ConsumerId BIGINT, @RoleId INT, @TransportConsumerStoppageMappingId INT,
            @AcademicYearId SMALLINT,
            @YouCanDelete INT;
    SET @YouCanDelete = 1;
    DECLARE @appliedDiscFeePaymentCount INT;
    DECLARE @appliedAdditionalDiscFeePaymentCount INT;
    SET @ConsumerId = (SELECT TOP 1 ConsumerId FROM TransportFeePayment WHERE IsDeleted <> 1 AND TransportFeePaymentId = @TransportFeePaymentId);
    SET @RoleId = (SELECT TOP 1 RoleId FROM TransportFeePayment WHERE IsDeleted <> 1 AND TransportFeePaymentId = @TransportFeePaymentId);
    SET @AcademicYearId = (SELECT TOP 1 AcademicYearId FROM TransportFeePayment WHERE IsDeleted <> 1 AND TransportFeePaymentId = @TransportFeePaymentId);
    SET @TransportConsumerStoppageMappingId = (SELECT TOP 1 TransportConsumerStoppageMappingId FROM TransportFeePayment WHERE IsDeleted <> 1 AND TransportFeePaymentId = @TransportFeePaymentId);
    IF EXISTS (SELECT TransportFeePaymentAppliedMonthMappingId FROM TransportFeePaymentAppliedMonthMapping WHERE ConsumerId = @ConsumerId AND TransportConsumerStoppageMappingId = @TransportConsumerStoppageMappingId AND RoleId = @RoleId AND AcademicYearId = @AcademicYearId AND TransportFeePaymentId = @TransportFeePaymentId AND IsDeleted <> 1)
    BEGIN
        SET @appliedDiscFeePaymentCount = (SELECT COUNT(TransportFeePaymentId) FROM TransportFeePayment WHERE ConsumerId = @ConsumerId AND TransportConsumerStoppageMappingId = @TransportConsumerStoppageMappingId AND RoleId = @RoleId  AND AcademicYearId = @AcademicYearId AND IsDeleted <> 1  AND TransportFeePaymentId > @TransportFeePaymentId)
    END
    IF EXISTS (SELECT TransportFeeAdditionalDiscountId FROM TransportFeeAdditionalDiscount WHERE ConsumerId = @ConsumerId AND TransportConsumerStoppageMappingId = @TransportConsumerStoppageMappingId AND RoleId = @RoleId  AND AcademicYearId = @AcademicYearId AND TransportFeePaymentId = @TransportFeePaymentId AND IsDeleted <> 1)
    BEGIN
        SET @appliedAdditionalDiscFeePaymentCount = (SELECT COUNT(TransportFeePaymentId) FROM TransportFeePayment WHERE ConsumerId = @ConsumerId AND TransportConsumerStoppageMappingId = @TransportConsumerStoppageMappingId AND RoleId = @RoleId  AND AcademicYearId = @AcademicYearId AND IsDeleted <> 1 AND TransportFeePaymentId > @TransportFeePaymentId)
    END


    IF @appliedDiscFeePaymentCount > 0 OR @appliedAdditionalDiscFeePaymentCount > 0
    BEGIN
        SET @YouCanDelete = 0;
    END

    IF @YouCanDelete = 1
    BEGIN
        UPDATE TransportFeePayment SET IsDeleted = 1,ModifiedBy = @UserId, ModifiedDate = GetDate() WHERE TransportFeePaymentId = @TransportFeePaymentId     
        UPDATE TransportFeePaymentDetails SET IsDeleted = 1,ModifiedBy = @UserId, ModifiedDate = GetDate() WHERE TransportFeePaymentId = @TransportFeePaymentId
        UPDATE TransportFeeAdditionalDiscount SET IsDeleted = 1,ModifiedBy = @UserId, ModifiedDate = GetDate() WHERE TransportFeePaymentId = @TransportFeePaymentId
        UPDATE TransportFeePaymentAppliedMonthMapping SET IsDeleted = 1,ModifiedBy = @UserId, ModifiedDate = GetDate() WHERE TransportFeePaymentId = @TransportFeePaymentId
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