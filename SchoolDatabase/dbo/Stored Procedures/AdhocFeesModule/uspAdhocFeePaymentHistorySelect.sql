-- =============================================
-- Author:    Deepak Walunj
-- Create date: 17/09/2023
-- Description:  This stored procedure is used to get Fee Payment history info detail by payment fee Id
-- =============================================
CREATE PROCEDURE [dbo].[uspAdhocFeePaymentHistorySelect]
	@AcademicYearId SMALLINT,
	@StudentId BIGINT,
	@GradeId SMALLINT,
	@DivisionId SMALLINT,
	@AdhocFeePaymentId BIGINT
AS BEGIN
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 
        DECLARE @FeePaymentTypeTable TABLE(
		   PaymentTypeId TINYINT,
		   PaymentTypeName NVARCHAR(50)
		  )
        INSERT INTO @FeePaymentTypeTable(PaymentTypeId, PaymentTypeName) VALUES (1,'Cash'),(2,'Cheque'),(3,'DD'),(4,'Credit/Debit Card'),(5,'Net Banking'),(6,'UPI Payment');
        
		-- 1st result for student info
        SELECT 
		s.FirstName + ' ' + s.MiddleName + ' ' + s.LastName AS 'StudentName',
		m.AcademicYearId,
		m.RollNumber,
		s.GeneralRegistrationNo,
		g.GradeName,
		d.DivisionName,
        (SELECT SchoolName FROM School) AS SchoolName,
		(SELECT ISNULL(SchoolAddressLine1,'') + IIF(SchoolAddressLine1 IS NULL,'',', ') + ISNULL(SchoolAddressLine2,'') + IIF(SchoolAddressLine2 IS NULL,'',', ') + TalukaName + ', ' + DistrictName + ', ' + StateName + ', ' + Pincode  FROM School) AS SchoolAddress,
		IIF(p.PaymentTypeId = 2 OR p.PaymentTypeId = 3, p.ChequeNumber, p.OnlineTransactionId) AS TransactionId,
		p.InvoiceNumber,
		t.PaymentTypeName,
		p.OnlineTransactionDateTime AS PaymentDate,
		p.ChequeDate AS ChequeDate,
		p.ChequeBank AS ChequeBank,
		p.TotalFee,
		apm.Particular
		FROM Student s
		INNER JOIN StudentGradeDivisionMapping m
		ON s.StudentId = m.StudentId
		INNER JOIN Grade g
		ON m.GradeId = m.GradeId
		INNER JOIN Division d
		ON m.DivisionId = d.DivisionId
		INNER JOIN AdhocFeePayment p
		ON p.StudentId = s.StudentId AND p.AcademicYearId = m.AcademicYearId AND p.AdhocFeePaymentId = @AdhocFeePaymentId
		INNER JOIN @FeePaymentTypeTable t
        ON p.PaymentTypeId = t.PaymentTypeId 
		INNER JOIN dbo.AdhocParticularMaster apm
		ON apm.AdhocParticularMasterId = p.ParticularId
		WHERE ISNULL(s.IsDeleted,0) <> 1
		AND ISNULL(s.IsArchive,0) <> 1
		AND ISNULL(m.IsDeleted,0) <> 1
		AND ISNULL(g.IsDeleted,0) <> 1
		AND ISNULL(d.IsDeleted,0) <> 1
		AND ISNULL(p.IsDeleted,0) <> 1
		AND m.AcademicYearId = @AcademicYearId
		AND m.StudentId = @StudentId
		AND m.GradeId = @GradeId
		AND m.DivisionId = @DivisionId
		AND g.GradeId = @GradeId
		AND d.DivisionId = @DivisionId

		
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