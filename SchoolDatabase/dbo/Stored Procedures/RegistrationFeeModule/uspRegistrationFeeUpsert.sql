-- =============================================
-- Author: Prerana Aher
-- Create date: 08/08/2024
-- Description: This stored procedure is used for doing Registration Fee Upsert
-- =============================================
CREATE PROCEDURE [dbo].[uspRegistrationFeeUpsert]
	@StudentEnquiryId INT,
	@AcademicYearId SMALLINT,
	@OnlineTransactionId VARCHAR(300),
	@OnlineTransactionDateTime DATETIME,
	@OnlinePaymentRequest varchar(1000),
	@OnlinePaymentResponse varchar(1000),
	@PaidToBank nvarchar(100), 
	@PaidAmount money,
	@PaymentTypeId smallint,
	@Remark nvarchar(200),
    @UserId INT,
    @RegistrationFeeDetails RegistrationFeeDetailsType READONLY
AS 
BEGIN 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;
DECLARE @RegistrationFeeId INT, @RegistrationInvoiceNumber VARCHAR(100)
DECLARE @CurrentDateTime DATETIME = GETDATE();
BEGIN TRY 
BEGIN TRANSACTION
	INSERT INTO RegistrationFee (
	StudentEnquiryId,
	AcademicYearId,
	OnlineTransactionId,
	OnlineTransactionDateTime,
	OnlinePaymentRequest,
	OnlinePaymentResponse,
	PaidToBank, 
	PaidAmount,
	PaymentTypeId,
	Remark,
	CreatedBy,
	CreatedDate
	)
	VALUES (
	@StudentEnquiryId,
	@AcademicYearId,
	@OnlineTransactionId,
	@OnlineTransactionDateTime,
	@OnlinePaymentRequest,
	@OnlinePaymentResponse,
	@PaidToBank, 
	@PaidAmount,
	@PaymentTypeId,
	@Remark,
	@UserId,
	@CurrentDateTime
	)
SET @RegistrationFeeId = SCOPE_IDENTITY();

DECLARE @RegistrationInvoiceNumberStartNumber BIGINT = (NEXT VALUE FOR dbo.RegistrationFeeInvoiceSequence);
		
DECLARE @RegistrationInvoiceNumberPrefix NVARCHAR(100) = (SELECT RegistrationFeeInvoiceNoPrefix FROM School);
SET @RegistrationInvoiceNumber = CONCAT(@RegistrationInvoiceNumberPrefix,(ISNULL(@RegistrationInvoiceNumberStartNumber,0)));

UPDATE RegistrationFee SET RegistrationInvoiceNumber = @RegistrationInvoiceNumber
WHERE RegistrationFeeId = @RegistrationFeeId
AND IsDeleted <> 1;

	INSERT INTO RegistrationFeeDetails(
	FeeParticularId,
	RegistrationFeeId,
	StudentEnquiryId,
	AcademicYearId,
	InvoiceNumber,
	PaidAmount,
	PaymentTypeId, 
	CreatedBy, 
	CreatedDate
	)
    SELECT 
	rd.FeeParticularId,
	@RegistrationFeeId,
	@StudentEnquiryId,
	@AcademicYearId,
    @RegistrationInvoiceNumber,
	rd.PaidAmount,
	@PaymentTypeId,
	@UserId,
	@CurrentDateTime
    FROM 
	@RegistrationFeeDetails rd

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
EXEC uspExceptionLogInsert 
@ErrorLine, 
@ErrorMessage, 
@ErrorNumber, 
@ErrorProcedure, 
@ErrorSeverity, 
@ErrorState END CATCH END
