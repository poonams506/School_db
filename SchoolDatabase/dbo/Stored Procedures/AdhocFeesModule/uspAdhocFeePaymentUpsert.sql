-- =============================================
-- Author:    Deepak Walunj
-- Create date: 25/08/2023
-- Description:  This stored procedure is used for doing actual fee payment
-- =============================================
CREATE PROCEDURE [dbo].[uspAdhocFeePaymentUpsert]
  @AcademicYearId SMALLINT, 
  @GradeId SMALLINT, 
  @DivisionId SMALLINT, 
  @StudentId BIGINT,
  @OnlineTransactionId VARCHAR(300) = NULL,
  @OnlineTransactionDateTime DATETIME = NULL,
  @OnlinePaymentRequest VARCHAR(1000) = NULL,
  @OnlinePaymentResponse VARCHAR(1000) = NULL,
  @PaidToBank NVARCHAR(100) = NULL,
  @TotalFee MONEY,
  @ParticularId SMALLINT,
  @PaymentTypeId SMALLINT,
  @ChequeNumber NVARCHAR(100) = NULL,
  @ChequeDate DATETIME = NULL,
  @ChequeBank NVARCHAR(100) = NULL,
  @ChequeAmount MONEY = NULL,
  @IsChequeClear BIT = NULL,
  @UserId INT
AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 
DECLARE @AdhocFeePaymentId BIGINT, @InvoiceNumber NVARCHAR(100);
DECLARE @CurrentDateTime DATETIME = GETDATE();
BEGIN TRY 
   BEGIN TRANSACTION
   -- insert fee payment table data
   INSERT INTO AdhocFeePayment (
   AcademicYearId,
   GradeId,
   DivisionId,
   StudentId,
   OnlineTransactionId,
   OnlineTransactionDateTime,
   OnlinePaymentRequest,
   OnlinePaymentResponse,
   TotalFee,
   ParticularId,
   PaymentTypeId,
   ChequeNumber,
   ChequeDate,
   ChequeBank,
   ChequeAmount,
   IsChequeClear,
   CreatedBy,
   CreatedDate
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
   @TotalFee,
   @ParticularId,
   @PaymentTypeId,
   @ChequeNumber,
   @ChequeDate,
   @ChequeBank,
   @ChequeAmount,
   @IsChequeClear,
   @UserId,
   @CurrentDateTime
   )
   SET @AdhocFeePaymentId = SCOPE_IDENTITY();

   DECLARE @InvoiceNoStartNumber BIGINT = (NEXT VALUE FOR dbo.AdditionalInvoiceSequence);
   DECLARE @InvoiceNoPrefix NVARCHAR(100) = (SELECT AdditionalFeeInvoiceNoPrefix FROM School);
   SET @InvoiceNumber = CONCAT(@InvoiceNoPrefix,(ISNULL(@InvoiceNoStartNumber,0)));
   -- update InvoiceNumber in main table
   UPDATE AdhocFeePayment
   SET InvoiceNumber = @InvoiceNumber,
    ModifiedBy=@UserId,
    ModifiedDate=@CurrentDateTime
   WHERE AdhocFeePaymentId = @AdhocFeePaymentId AND IsDeleted <> 1;

   
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