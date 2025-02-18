-- =============================================
-- Author:    Deepak Walunj
-- Create date: 25/08/2023
-- Description:  This stored procedure is used for doing actual fee payment
-- =============================================
CREATE PROCEDURE [dbo].[uspTransportFeePaymentUpsert]
  @AcademicYearId SMALLINT, 
  @RoleId INT, 
  @ConsumerId BIGINT,
  @TransportConsumerStoppageMappingId INT,
  @OnlineTransactionId VARCHAR(300) = NULL,
  @OnlineTransactionDateTime DATETIME = NULL,
  @OnlinePaymentRequest VARCHAR(1000) = NULL,
  @OnlinePaymentResponse VARCHAR(1000) = NULL,
  @PaidToBank NVARCHAR(100) = NULL,
  @PaidAmount MONEY,
  @PaymentTypeId SMALLINT,
  @ChequeNumber NVARCHAR(100) = NULL,
  @ChequeDate DATETIME = NULL,
  @ChequeBank NVARCHAR(100) = NULL,
  @ChequeAmount MONEY = NULL,
  @IsChequeClear BIT = NULL,
  @Remark NVARCHAR(100) = NULL,
  @AdditionalDiscountedAmount MONEY = NULL,
  @InstallmentPaybleFee MONEY = NULL,
  @AdditionalDiscountedRemark NVARCHAR(200)= NULL,
  @UserId INT,
  @TransportFeePaymentAppliedMonthMapping TransportFeePaymentAppliedMonthMappingType READONLY,
  @TransportFeePaymentDetails TransportFeePaymentDetailType READONLY
AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 
DECLARE @TransportFeePaymentId BIGINT, @InvoiceNumber NVARCHAR(100);
DECLARE @CurrentDateTime DATETIME = GETDATE();
BEGIN TRY 
   BEGIN TRANSACTION
   -- insert transport fee payment table data
   INSERT INTO TransportFeePayment (
   AcademicYearId,
   RoleId,
   ConsumerId,
   TransportConsumerStoppageMappingId,
   OnlineTransactionId,
   OnlineTransactionDateTime,
   OnlinePaymentRequest,
   OnlinePaymentResponse,
   PaidAmount,
   PaymentTypeId,
   ChequeNumber,
   ChequeDate,
   ChequeBank,
   ChequeAmount,
   IsChequeClear,
   Remark,
   CreatedBy,
   CreatedDate
   )
   VALUES(
   @AcademicYearId,
   @RoleId,
   @ConsumerId,
   @TransportConsumerStoppageMappingId,
   @OnlineTransactionId,
   @OnlineTransactionDateTime,
   @OnlinePaymentRequest,
   @OnlinePaymentResponse,
   @PaidAmount,
   @PaymentTypeId,
   @ChequeNumber,
   @ChequeDate,
   @ChequeBank,
   @ChequeAmount,
   @IsChequeClear,
   @Remark,
   @UserId,
   @CurrentDateTime
   )
   SET @TransportFeePaymentId = SCOPE_IDENTITY();

   DECLARE @InvoiceNoStartNumber BIGINT = (NEXT VALUE FOR dbo.TransportInvoiceSequence);
   --IF @InvoiceNoStartNumber > 0
   --BEGIN
   --     SET @InvoiceNoStartNumber = @InvoiceNoStartNumber - 1;
   --END

   DECLARE @InvoiceNoPrefix NVARCHAR(100) = (SELECT TransportInvoiceNoPrefix FROM School);
   SET @InvoiceNumber = CONCAT(@InvoiceNoPrefix,(ISNULL(@InvoiceNoStartNumber,0)));
   -- update InvoiceNumber in main table
   UPDATE TransportFeePayment SET InvoiceNumber = @InvoiceNumber WHERE TransportFeePaymentId = @TransportFeePaymentId AND IsDeleted <> 1;

  --Insert TransportFeePaymentDetails table details
  INSERT INTO TransportFeePaymentDetails (
   RoleId,
   ConsumerId,
   TransportConsumerStoppageMappingId,
   AcademicYearId,
   TransportFeePaymentId,
   InvoiceNumber,
   OtherFeeReason,
   FeeAfterDiscount,
   PaidAmount,
   IsChequeClear,
   PaymentTypeId,
   AdditionalDiscInPercentage,
   AdditionalDiscAmount,
   CreatedBy,
   CreatedDate
   )
   SELECT 
   @RoleId,
   @ConsumerId,
   @TransportConsumerStoppageMappingId,
   @AcademicYearId,
   @TransportFeePaymentId,
   @InvoiceNumber,
   d.OtherFeeReason,
   d.FeeAfterDiscount,
   d.PaidAmount,
   @IsChequeClear,
   @PaymentTypeId,
   d.AdditionalDiscInPercentage,
   d.AdditionalDiscAmount,
   @UserId,
   @CurrentDateTime
   FROM 
   @TransportFeePaymentDetails d


   DECLARE @TransportFeeAdditionalDiscountId BIGINT;
   --Insert TransportFeeAdditionalDiscount table details
   IF(@AdditionalDiscountedAmount > 0)
   BEGIN
   INSERT INTO TransportFeeAdditionalDiscount(
    ConsumerId,
	TransportConsumerStoppageMappingId,
	RoleId,
    AcademicYearId,
    TransportFeePaymentId,
	AdditionalDiscountedAmount,
	InstallmentPaybleFee,
	AdditionalDiscountedRemark,
	CreatedBy, 
	CreatedDate
   )
   VALUES
   (
    @ConsumerId,
	@TransportConsumerStoppageMappingId,
	@RoleId,
    @AcademicYearId,
	@TransportFeePaymentId,
	@AdditionalDiscountedAmount,
	@InstallmentPaybleFee,
	@AdditionalDiscountedRemark,
	@UserId,
	@CurrentDateTime
   )
   SET @TransportFeeAdditionalDiscountId = SCOPE_IDENTITY();
   END

      --Insert TransportFeePaymentAppliedMonthMapping table details
   INSERT INTO TransportFeePaymentAppliedMonthMapping (
   ConsumerId,
   TransportConsumerStoppageMappingId,
   RoleId,
   AcademicYearId,
   TransportFeePaymentId,
   MonthMasterId,
   TransportFeeAdditionalDiscountId,
   CreatedBy,
   CreatedDate
   )
   SELECT 
   @ConsumerId,
   @TransportConsumerStoppageMappingId,
   @RoleId,
   @AcademicYearId,
   @TransportFeePaymentId,
   m.MonthMasterId,
   @TransportFeeAdditionalDiscountId,
   @UserId,
   @CurrentDateTime
   FROM 
   @TransportFeePaymentAppliedMonthMapping m

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
@ErrorState END CATCH END