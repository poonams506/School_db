-- =============================================
-- Author:    Deepak Walunj
-- Create date: 25/08/2023
-- Description:  This stored procedure is used for doing actual fee payment
-- =============================================
CREATE PROCEDURE [dbo].[uspFeePaymentUpsert]
  @AcademicYearId SMALLINT, 
  @GradeId SMALLINT, 
  @DivisionId SMALLINT, 
  @StudentId BIGINT,
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
  @SkipDiscount BIT,
  @FeeWavierTypesInstallmentsDetailsId BIGINT = NULL,
  @FeePaymentAppliedWavierMapping FeePaymentAppliedWavierMappingType READONLY,
  @FeePaymentDetails FeePaymentDetailType READONLY
AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 
DECLARE @FeePaymentId BIGINT, @InvoiceNumber NVARCHAR(100);
DECLARE @CurrentDateTime DATETIME = GETDATE();
BEGIN TRY 
   BEGIN TRANSACTION
   -- insert fee payment table data
   INSERT INTO FeePayment (
   AcademicYearId,
   GradeId,
   DivisionId,
   StudentId,
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
   CreatedDate,
   SkipDiscount,
   FeeWavierTypesInstallmentsDetailsId
   )
   VALUES(
   @AcademicYearId,
   @GradeId,
   @DivisionId,
   @StudentId,
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
   @CurrentDateTime,
   @SkipDiscount,
   @FeeWavierTypesInstallmentsDetailsId
   )
   SET @FeePaymentId = SCOPE_IDENTITY();

   DECLARE @InvoiceNoStartNumber BIGINT = (NEXT VALUE FOR dbo.InvoiceSequence);
   --IF @InvoiceNoStartNumber > 0
   --BEGIN
   --     SET @InvoiceNoStartNumber = @InvoiceNoStartNumber - 1;
   --END

   DECLARE @InvoiceNoPrefix NVARCHAR(100) = (SELECT InvoiceNoPrefix FROM School);
   SET @InvoiceNumber = CONCAT(@InvoiceNoPrefix,(ISNULL(@InvoiceNoStartNumber,0)));
   -- update InvoiceNumber in main table
   UPDATE FeePayment SET InvoiceNumber = @InvoiceNumber WHERE FeePaymentId = @FeePaymentId AND IsDeleted <> 1;

  --Insert FeePaymentDetails table details
  INSERT INTO FeePaymentDetails (
   FeeParticularId,
   StudentId,
   AcademicYearId,
   FeePaymentId,
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
   d.FeeParticularId,
   @StudentId,
   @AcademicYearId,
   @FeePaymentId,
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
   @FeePaymentDetails d

   --Insert FeePaymentAppliedWavierMapping table details
   INSERT INTO FeePaymentAppliedWavierMapping (
   StudentId,
   AcademicYearId,
   FeePaymentId,
   FeeParticularWavierMappingId,
   DiscountedPercent,
   DiscountedAmount,
   CreatedBy,
   CreatedDate
   )
   SELECT 
   @StudentId,
   @AcademicYearId,
   @FeePaymentId,
   m.FeeParticularWavierMappingId,
   m.DiscountedPercent,
   m.DiscountedAmount,
   @UserId,
   @CurrentDateTime
   FROM 
   @FeePaymentAppliedWavierMapping m

   --Insert FeeAdditionalDiscount table details
   IF(@AdditionalDiscountedAmount > 0)
   BEGIN
   INSERT INTO FeeAdditionalDiscount(
    StudentId,
    AcademicYearId,
    FeePaymentId,
	AdditionalDiscountedAmount,
	InstallmentPaybleFee,
	AdditionalDiscountedRemark,
	CreatedBy, 
	CreatedDate
   )
   VALUES
   (
    @StudentId,
    @AcademicYearId,
	@FeePaymentId,
	@AdditionalDiscountedAmount,
	@InstallmentPaybleFee,
	@AdditionalDiscountedRemark,
	@UserId,
	@CurrentDateTime
   )
   END
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