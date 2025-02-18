-- =============================================
-- Author:    Deepak Walunj
-- Create date: 25/08/2023
-- Description:  This stored procedure is used for doing actual fee payment
-- =============================================
CREATE PROCEDURE [dbo].[uspStudentKitFeePaymentUpsert]
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
  @StudentKitFeePaymentDetails StudentKitFeePaymentDetailType READONLY
AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 
DECLARE @StudentKitFeePaymentId BIGINT, @InvoiceNumber NVARCHAR(100);
DECLARE @CurrentDateTime DATETIME = GETDATE();
BEGIN TRY 
   BEGIN TRANSACTION
   -- insert fee payment table data
   INSERT INTO StudentKitFeePayment (
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
   SkipDiscount
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
   @SkipDiscount
   )
   SET @StudentKitFeePaymentId = SCOPE_IDENTITY();

   DECLARE @InvoiceNoStartNumber BIGINT = (NEXT VALUE FOR dbo.SchoolKitInvoiceSequence);
   --IF @InvoiceNoStartNumber > 0
   --BEGIN
   --     SET @InvoiceNoStartNumber = @InvoiceNoStartNumber - 1;
   --END

   DECLARE @InvoiceNoPrefix NVARCHAR(100) = (SELECT SchoolKitInvoiceNoPrefix FROM School);
   SET @InvoiceNumber = CONCAT(@InvoiceNoPrefix,(ISNULL(@InvoiceNoStartNumber,0)));
   -- update InvoiceNumber in main table
   UPDATE StudentKitFeePayment SET InvoiceNumber = @InvoiceNumber WHERE StudentKitFeePaymentId = @StudentKitFeePaymentId AND IsDeleted <> 1;

  --Insert FeePaymentDetails table details
  INSERT INTO StudentKitFeePaymentDetails (
   FeeParticularId,
   StudentId,
   AcademicYearId,
   StudentKitFeePaymentId,
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
   @StudentKitFeePaymentId,
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
   @StudentKitFeePaymentDetails d


   --Insert FeeAdditionalDiscount table details
   IF(@AdditionalDiscountedAmount > 0)
   BEGIN
   INSERT INTO StudentKitFeeAdditionalDiscount(
    StudentId,
    AcademicYearId,
    StudentKitFeePaymentId,
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
	@StudentKitFeePaymentId,
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