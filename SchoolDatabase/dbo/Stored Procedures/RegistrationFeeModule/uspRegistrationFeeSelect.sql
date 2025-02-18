--===============================================
-- Author:- Prerana Aher 
-- Create date:- 08/08/2024
-- Description:- This stored procedure is used to get RegistrationFee by Select.
-- =============================================
CREATE PROCEDURE [dbo].[uspRegistrationFeeSelect]
(
	@StudentEnquiryId INT,
	@AcademicYearId SMALLINT
)
AS 
BEGIN
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;
BEGIN TRY 
	-- 1st result for student info
	SELECT 
	se.StudentFirstName + ' '+ se.StudentMiddleName + ' ' + se.StudentLastName AS 'StudentFullName',
	r.OnlineTransactionId,
	r.PaidToBank,
	r.PaymentTypeId,
	r.AcademicYearId,
	(SELECT Count(RegistrationFeeId) FROM RegistrationFee
	WHERE AcademicYearId = r.AcademicYearId AND IsDeleted <> 1 AND StudentEnquiryId = se.StudentEnquiryId) AS 'PaymentInstallmentDone'
	FROM RegistrationFee r
	INNER JOIN StudentEnquiry se ON r.StudentEnquiryId = se.StudentEnquiryId
	WHERE ISNULL(se.IsDeleted,0) <> 1
	AND ISNULL(r.IsDeleted,0) <> 1
	AND r.AcademicYearId = @AcademicYearId
	AND se.StudentEnquiryId = @StudentEnquiryId


	-- 2nd result for Particulars
	SELECT 
	rd.FeeParticularId,
	f.AdhocParticularMasterId,
	f.Particular as ParticularName,
	ISNULL(rd.PaidAmount,0) AS 'TotalFee',
	ISNULL(SUM(rd.PaidAmount),0) AS 'AlreadyPaid'
	FROM 
	AdhocParticularMaster f
	LEFT JOIN RegistrationFeeDetails rd ON rd.FeeParticularId = f.AdhocParticularMasterId 
	AND rd.AcademicYearId = @AcademicYearId 
	AND rd.IsDeleted <> 1
	WHERE 
	ISNULL(f.IsDeleted,0) <> 1
	AND ISNULL(rd.IsDeleted,0) <> 1
	AND rd.AcademicYearId = @AcademicYearId
	GROUP BY rd.FeeParticularId,f.AdhocParticularMasterId,f.Particular, rd.PaidAmount
	
END TRY 
BEGIN CATCH 
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
@ErrorState;
END CATCH
END