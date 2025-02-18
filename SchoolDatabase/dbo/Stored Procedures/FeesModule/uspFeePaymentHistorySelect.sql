-- =============================================
-- Author:    Deepak Walunj
-- Create date: 17/09/2023
-- Description:  This stored procedure is used to get Fee Payment history info detail by payment fee Id
-- =============================================
CREATE PROCEDURE [dbo].[uspFeePaymentHistorySelect]
	@AcademicYearId SMALLINT,
	@StudentId BIGINT,
	@GradeId SMALLINT,
	@DivisionId SMALLINT,
	@FeePaymentId BIGINT
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
		p.ChequeBank AS ChequeBank
		FROM Student s
		INNER JOIN StudentGradeDivisionMapping m
		ON s.StudentId = m.StudentId
		INNER JOIN Grade g
		ON m.GradeId = m.GradeId
		INNER JOIN Division d
		ON m.DivisionId = d.DivisionId
		INNER JOIN FeePayment p
		ON p.StudentId = s.StudentId AND p.AcademicYearId = m.AcademicYearId AND p.FeePaymentId = @FeePaymentId
		INNER JOIN @FeePaymentTypeTable t
        ON p.PaymentTypeId = t.PaymentTypeId 
		WHERE ISNULL(s.IsDeleted,0) <> 1
		AND ISNULL(m.IsDeleted,0) <> 1
		AND s.IsArchive <> 1
		AND ISNULL(g.IsDeleted,0) <> 1
		AND ISNULL(d.IsDeleted,0) <> 1
		AND ISNULL(p.IsDeleted,0) <> 1
		AND m.AcademicYearId = @AcademicYearId
		AND m.StudentId = @StudentId
		AND m.GradeId = @GradeId
		AND m.DivisionId = @DivisionId
		AND g.GradeId = @GradeId
		AND d.DivisionId = @DivisionId

		--2nd result for Particulars

		DECLARE @noOfInstallment INT;
		SET @noOfInstallment = (SELECT TOP 1 NumberOfInstallments FROM FeeWavierTypes fwt
		INNER JOIN FeeParticularWavierMapping fpwm
		ON fwt.FeeWavierTypeId = fpwm.FeeWavierTypeId
		INNER JOIN FeePaymentAppliedWavierMapping awm
		ON fpwm.FeeParticularWavierMappingId = awm.FeeParticularWavierMappingId
		WHERE awm.AcademicYearId = @AcademicYearId
		AND fpwm.AcademicYearId = @AcademicYearId
		AND awm.FeePaymentId = @FeePaymentId
		AND awm.StudentId = @StudentId
		AND fpwm.IsDeleted <> 1
		AND awm.IsDeleted <> 1);

		SET @noOfInstallment = ISNULL(@noOfInstallment,1);

		DECLARE @InstallmentPaidTable TABLE(
		FeeParticularId BIGINT,
		FeeAfterDiscount MONEY,
		PaidAmount MONEY
		)
		INSERT INTO @InstallmentPaidTable
		SELECT 
		f.FeeParticularId,
		ISNULL(d.FeeAfterDiscount,0) AS 'FeeAfterDiscount',
		ISNULL(d.PaidAmount,0) AS 'PaidAmount'
		FROM 
		FeeParticular f
		INNER JOIN StudentGradeDivisionMapping m
		ON f.GradeId = m.GradeId AND f.DivisionId = m.DivisionId
		INNER JOIN Student s
		ON m.StudentId = s.StudentId
		INNER JOIN FeePaymentDetails d
		ON d.FeeParticularId = f.FeeParticularId AND s.StudentId = d.StudentId AND d.AcademicYearId = @AcademicYearId AND d.FeePaymentId = @FeePaymentId
		WHERE 
		ISNULL(f.IsDeleted,0) <> 1
		AND ISNULL(m.IsDeleted,0) <> 1
		AND ISNULL(s.IsDeleted,0) <> 1
		AND ISNULL(s.IsArchive,0) <> 1
		AND ISNULL(d.IsDeleted,0) <> 1
		AND f.AcademicYearId = @AcademicYearId
		AND m.AcademicYearId = @AcademicYearId
		AND s.StudentId = @StudentId
		AND f.IsPublished = 1 
		AND d.FeePaymentId = @FeePaymentId


		DECLARE @InstallmentAlreadyPaidTable TABLE(
		FeeParticularId BIGINT,
		AlreadyPaid MONEY
		)
		INSERT INTO @InstallmentAlreadyPaidTable
		SELECT 
		f.FeeParticularId,
		ISNULL(SUM(d.PaidAmount),0) AS 'AlreadyPaid'
		FROM 
		FeeParticular f
		INNER JOIN StudentGradeDivisionMapping m
		ON f.GradeId = m.GradeId AND f.DivisionId = m.DivisionId
		INNER JOIN Student s
		ON m.StudentId = s.StudentId
		INNER JOIN FeePaymentDetails d
		ON d.FeeParticularId = f.FeeParticularId AND s.StudentId = d.StudentId AND d.AcademicYearId = @AcademicYearId AND d.FeePaymentId < @FeePaymentId
		WHERE 
		ISNULL(f.IsDeleted,0) <> 1
		AND ISNULL(m.IsDeleted,0) <> 1
		AND ISNULL(s.IsDeleted,0) <> 1
		AND ISNULL(s.IsArchive,0) <> 1
		AND ISNULL(d.IsDeleted,0) <> 1
		AND f.AcademicYearId = @AcademicYearId
		AND m.AcademicYearId = @AcademicYearId
		AND s.StudentId = @StudentId
		AND f.IsPublished = 1 
		AND d.FeePaymentId < @FeePaymentId
		GROUP BY f.FeeParticularId;

		
		with cte as(
		SELECT
		f.FeeParticularId,
		f.ParticularName,
		ISNULL(f.Amount,0) AS 'TotalFee',
		pt.FeeAfterDiscount,
		pt.PaidAmount,
		ISNULL(apt.AlreadyPaid,0) AS AlreadyPaid,
		ISNULL(pt.FeeAfterDiscount - (pt.PaidAmount + ISNULL(apt.AlreadyPaid,0)),0) AS DueAmount,
		f.SortBy
		FROM 
		FeeParticular f
		INNER JOIN StudentGradeDivisionMapping m
		ON f.GradeId = m.GradeId AND f.DivisionId = m.DivisionId
		INNER JOIN Student s
		ON m.StudentId = s.StudentId
		LEFT JOIN @InstallmentPaidTable pt
		ON f.FeeParticularId = pt.FeeParticularId
		LEFT JOIN @InstallmentAlreadyPaidTable apt
		ON f.FeeParticularId = apt.FeeParticularId
		WHERE 
		ISNULL(f.IsDeleted,0) <> 1
		AND ISNULL(m.IsDeleted,0) <> 1
		AND ISNULL(s.IsDeleted,0) <> 1
		AND ISNULL(s.IsArchive,0) <> 1
		AND f.AcademicYearId = @AcademicYearId
		AND m.AcademicYearId = @AcademicYearId
		AND m.StudentId = @StudentId
		AND s.StudentId = @StudentId
		AND f.IsPublished = 1
		AND m.IsRTEStudent <> 1

		UNION

		SELECT
		f.FeeParticularId,
		f.ParticularName,
		ISNULL(f.Amount,0) AS 'TotalFee',
		pt.FeeAfterDiscount,
		pt.PaidAmount,
		ISNULL(apt.AlreadyPaid,0) AS AlreadyPaid,
		ISNULL(pt.FeeAfterDiscount - (pt.PaidAmount + ISNULL(apt.AlreadyPaid,0)),0) AS DueAmount,
		f.SortBy
		FROM 
		FeeParticular f
		INNER JOIN StudentGradeDivisionMapping m
		ON f.GradeId = m.GradeId AND f.DivisionId = m.DivisionId
		INNER JOIN Student s
		ON m.StudentId = s.StudentId
		LEFT JOIN @InstallmentPaidTable pt
		ON f.FeeParticularId = pt.FeeParticularId
		LEFT JOIN @InstallmentAlreadyPaidTable apt
		ON f.FeeParticularId = apt.FeeParticularId
		WHERE 
		ISNULL(f.IsDeleted,0) <> 1
		AND ISNULL(m.IsDeleted,0) <> 1
		AND ISNULL(s.IsDeleted,0) <> 1
		AND ISNULL(s.IsArchive,0) <> 1
		AND f.AcademicYearId = @AcademicYearId
		AND m.AcademicYearId = @AcademicYearId
		AND m.StudentId = @StudentId
		AND s.StudentId = @StudentId
		AND f.IsPublished = 1
		AND m.IsRTEStudent = 1
		AND f.IsRTEApplicable = 1

		
		)

		SELECT * FROM cte ORDER BY cte.SortBy ASC
		
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