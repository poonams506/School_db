-- =============================================
-- Author:    Deepak Walunj
-- Create date: 31/08/2023
-- Description:  This stored procedure is used to get Fee Payment info detail by student Id
-- =============================================
CREATE PROCEDURE [dbo].[uspParentAppFeePaymentSelect]
	@StudentId BIGINT,
	@AcademicYearId SMALLINT
AS BEGIN
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 
        DECLARE @GradeId SMALLINT;
	    DECLARE @DivisionId SMALLINT;
		SET @GradeId = (SELECT GradeId FROM StudentGradeDivisionMapping WHERE AcademicYearId = @AcademicYearId AND IsDeleted <> 1 AND StudentId = @StudentId);
		SET @DivisionId = (SELECT DivisionId FROM StudentGradeDivisionMapping WHERE AcademicYearId = @AcademicYearId AND IsDeleted <> 1 AND StudentId = @StudentId);
        DECLARE @FeeWavierTypeId BIGINT;

		-- 1nd result for Discount Fee
		SELECT DISTINCT @FeeWavierTypeId= 
		w.FeeWavierTypeId
		FROM 
		FeePaymentAppliedWavierMapping m
		INNER JOIN FeePayment p
		ON m.FeePaymentId = p.FeePaymentId
		INNER JOIN FeeParticularWavierMapping fwm
		ON m.FeeParticularWavierMappingId = fwm.FeeParticularWavierMappingId
		INNER JOIN FeeWavierTypes w
		ON w.FeeWavierTypeId = fwm.FeeWavierTypeId
		WHERE ISNULL(p.IsDeleted,0) <> 1
		AND ISNULL(m.IsDeleted,0) <> 1
		AND w.IsDeleted <> 1
		AND m.AcademicYearId = @AcademicYearId
		AND w.AcademicYearId = @AcademicYearId
		AND fwm.AcademicYearId = @AcademicYearId
	    AND p.StudentId = @StudentId
		AND p.AcademicYearId = @AcademicYearId

		SELECT 
		dbo.udfStudentTotalFee(@GradeId, @DivisionId, @AcademicYearId, @StudentId) AS 'TotalFee',
		dbo.udfStudentPaidAmount(@GradeId, @DivisionId, @AcademicYearId, @StudentId) AS 'TotalPaid',
		dbo.udfStudentDueAmount(@GradeId, @DivisionId, @AcademicYearId, @StudentId) AS 'TotalDue',
		dbo.udfStudentDiscountedFee(@GradeId, @DivisionId, @AcademicYearId, @StudentId) AS 'TotalDiscount',
		@FeeWavierTypeId AS 'FeeWavierTypeId'

		-- 2nd result for Particulars
		SELECT 
		f.FeeParticularId,
		f.ParticularName,
		f.IsDiscountApplicable,
		ISNULL(f.Amount,0) AS 'TotalFee',
		ISNULL(SUM(d.PaidAmount),0) AS 'AlreadyPaid'
		FROM 
		FeeParticular f
		INNER JOIN StudentGradeDivisionMapping m
		ON f.GradeId = m.GradeId AND f.DivisionId = m.DivisionId
		INNER JOIN Student s
		ON m.StudentId = s.StudentId
		LEFT JOIN FeePaymentDetails d
		ON d.FeeParticularId = f.FeeParticularId AND s.StudentId = d.StudentId AND d.AcademicYearId = @AcademicYearId AND d.IsDeleted <> 1
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
		AND m.IsRTEStudent <> 1
		GROUP BY f.FeeParticularId,f.ParticularName, f.Amount,f.IsDiscountApplicable

		UNION

		SELECT 
		f.FeeParticularId,
		f.ParticularName,
		f.IsDiscountApplicable,
		ISNULL(f.Amount,0) AS 'TotalFee',
		ISNULL(SUM(d.PaidAmount),0) AS 'AlreadyPaid'
		FROM 
		FeeParticular f
		INNER JOIN StudentGradeDivisionMapping m
		ON f.GradeId = m.GradeId AND f.DivisionId = m.DivisionId
		INNER JOIN Student s
		ON m.StudentId = s.StudentId
		LEFT JOIN FeePaymentDetails d
		ON d.FeeParticularId = f.FeeParticularId AND s.StudentId = d.StudentId AND d.AcademicYearId = @AcademicYearId AND d.IsDeleted <> 1
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
		AND m.IsRTEStudent = 1
		AND f.IsRTEApplicable = 1
		GROUP BY f.FeeParticularId,f.ParticularName, f.Amount,f.IsDiscountApplicable

		-- 3rd section
		
		DECLARE @TotalFee MONEY = 0;
		DECLARE @TotalFeeWithRTE MONEY = 0;
		DECLARE @TotalFeeWithOutRTE MONEY =0;

		DECLARE @TotalFeeDiscountApplicable MONEY = 0;
		DECLARE @TotalFeeWithRTEDiscountApplicable MONEY = 0;
		DECLARE @TotalFeeWithOutRTEDiscountApplicable MONEY =0;

		SELECT @TotalFeeWithOutRTE = ISNULL(SUM(f.Amount),0) FROM FeeParticular f
				INNER JOIN StudentGradeDivisionMapping m
				ON f.GradeId = m.GradeId AND f.DivisionId = m.DivisionId
				INNER JOIN Student s
				ON m.StudentId = s.StudentId
				WHERE 
				ISNULL(f.IsDeleted,0) <> 1
				AND ISNULL(m.IsDeleted,0) <> 1
				AND ISNULL(s.IsDeleted,0) <> 1
				AND ISNULL(s.IsArchive,0) <> 1
				AND f.AcademicYearId = @AcademicYearId
				AND m.AcademicYearId = @AcademicYearId
				AND m.GradeId = @GradeId
				AND m.DivisionId = @DivisionId
				AND ISNULL(F.IsPublished,0) = 1
				AND s.StudentId = @StudentId
				AND m.IsRTEStudent <> 1

		SELECT @TotalFeeWithRTE = ISNULL(SUM(f.Amount),0) FROM FeeParticular f
				INNER JOIN StudentGradeDivisionMapping m
				ON f.GradeId = m.GradeId AND f.DivisionId = m.DivisionId
				INNER JOIN Student s
				ON m.StudentId = s.StudentId
				WHERE 
				ISNULL(f.IsDeleted,0) <> 1
				AND ISNULL(m.IsDeleted,0) <> 1
				AND ISNULL(s.IsDeleted,0) <> 1
				AND ISNULL(s.IsArchive,0) <> 1
				AND f.AcademicYearId = @AcademicYearId
				AND m.AcademicYearId = @AcademicYearId
				AND m.GradeId = @GradeId
				AND m.DivisionId = @DivisionId
				AND ISNULL(F.IsPublished,0) = 1
				AND s.StudentId = @StudentId
				AND m.IsRTEStudent = 1
				AND f.IsRTEApplicable = 1

		SET @TotalFee = @TotalFeeWithRTE + @TotalFeeWithOutRTE;

		SELECT @TotalFeeWithOutRTEDiscountApplicable = ISNULL(SUM(f.Amount),0) FROM FeeParticular f
				INNER JOIN StudentGradeDivisionMapping m
				ON f.GradeId = m.GradeId AND f.DivisionId = m.DivisionId
				INNER JOIN Student s
				ON m.StudentId = s.StudentId
				WHERE 
				ISNULL(f.IsDeleted,0) <> 1
				AND ISNULL(m.IsDeleted,0) <> 1
				AND ISNULL(s.IsDeleted,0) <> 1
				AND ISNULL(s.IsArchive,0) <> 1
				AND f.AcademicYearId = @AcademicYearId
				AND m.AcademicYearId = @AcademicYearId
				AND m.GradeId = @GradeId
				AND m.DivisionId = @DivisionId
				AND ISNULL(F.IsPublished,0) = 1
				AND s.StudentId = @StudentId
				AND m.IsRTEStudent <> 1
				AND F.IsDiscountApplicable = 1

		SELECT @TotalFeeWithRTEDiscountApplicable = ISNULL(SUM(f.Amount),0) FROM FeeParticular f
				INNER JOIN StudentGradeDivisionMapping m
				ON f.GradeId = m.GradeId AND f.DivisionId = m.DivisionId
				INNER JOIN Student s
				ON m.StudentId = s.StudentId
				WHERE 
				ISNULL(f.IsDeleted,0) <> 1
				AND ISNULL(m.IsDeleted,0) <> 1
				AND ISNULL(s.IsDeleted,0) <> 1
				AND ISNULL(s.IsArchive,0) <> 1
				AND f.AcademicYearId = @AcademicYearId
				AND m.AcademicYearId = @AcademicYearId
				AND m.GradeId = @GradeId
				AND m.DivisionId = @DivisionId
				AND ISNULL(F.IsPublished,0) = 1
				AND s.StudentId = @StudentId
				AND m.IsRTEStudent = 1
				AND f.IsRTEApplicable = 1
				AND F.IsDiscountApplicable = 1

		SET @TotalFeeDiscountApplicable = @TotalFeeWithRTEDiscountApplicable + @TotalFeeWithOutRTEDiscountApplicable;

		-- FeeParticularWavierMapping list

		DECLARE @CurrentInstallment INT = 0;
		SELECT @CurrentInstallment = Count(FeePaymentId) + 1 FROM FeePayment
				WHERE AcademicYearId = @AcademicYearId AND IsDeleted <> 1 AND StudentId = @StudentId AND GradeId = @GradeId AND DivisionId = @DivisionId

		DECLARE @DiscountDateTable TABLE(
		InstallmentNumber INT,
		DiscountEndDate DATETIME,
		FeeWavierTypeId BIGINT,
		FeeWavierTypesInstallmentsDetailsId BIGINT,
		FeeWavierDisplayName NVARCHAR(200)
		)
		INSERT INTO @DiscountDateTable
		SELECT
		  ROW_NUMBER() OVER(partition by d.FeeWavierTypeId order by d.FeeWavierTypesInstallmentsDetailsId, d.FeeWavierTypeId asc) AS InstallmentNumber,
		  d.DiscountEndDate,
		  d.FeeWavierTypeId,
		  d.FeeWavierTypesInstallmentsDetailsId,
		  fwt.FeeWavierDisplayName
		FROM
			 FeeParticularWavierMapping f
			 INNER JOIN FeeWavierTypes fwt
			 ON f.AcademicYearId = fwt.AcademicYearId AND f.FeeWavierTypeId = fwt.FeeWavierTypeId
			 INNER JOIN FeeWavierTypesInstallmentsDetails d
			 ON fwt.FeeWavierTypeId = d.FeeWavierTypeId and fwt.AcademicYearId = @AcademicYearId and d.AcademicYearId = @AcademicYearId
		WHERE ISNULL(f.IsDeleted,0) <> 1
			 AND ISNULL(fwt.IsDeleted,0) <> 1
			 AND d.IsDeleted <> 1
			 AND fwt.IsActive = 1
			 AND f.GradeId = @GradeId 
			 AND f.DivisionId = @DivisionId
			 AND f.AcademicYearId = @AcademicYearId

		SELECT
			@TotalFee AS TotalFee,
			f.FeeParticularWavierMappingId,
			f.GradeId,
			f.DivisionId,
			f.FeeWavierTypeId,
			f.SortBy,
			fwt.FeeWavierDisplayName,
			fwt.FeeWavierTypeName,
			fwt.DiscountInPercent * 100 AS DiscountInPercent,
			fwt.LatePerDayFeeInPercent * 100 AS LatePerDayFeeInPercent,
			fwt.NumberOfInstallments,
			@TotalFee - ISNULL(@TotalFeeDiscountApplicable * fwt.DiscountInPercent,0) AS 'ApplicableFee',
			(SELECT Min(fd.LateFeeStartDate) FROM FeeWavierTypesInstallmentsDetails fd WHERE fd.FeeWavierTypeId = fwt.FeeWavierTypeId AND fd.IsDeleted <> 1) AS LateFeeStartDate,
			(SELECT DiscountEndDate FROM @DiscountDateTable WHERE FeeWavierTypeId = fwt.FeeWavierTypeId AND InstallmentNumber = @CurrentInstallment) AS DiscountEndDate
		FROM
			 FeeParticularWavierMapping f
			 INNER JOIN FeeWavierTypes fwt
			 ON f.AcademicYearId = fwt.AcademicYearId AND f.FeeWavierTypeId = fwt.FeeWavierTypeId
		WHERE ISNULL(f.IsDeleted,0) <> 1
			 AND ISNULL(fwt.IsDeleted,0) <> 1
			 AND fwt.IsActive = 1
			 AND f.GradeId = @GradeId 
			 AND f.DivisionId = @DivisionId
			 AND f.AcademicYearId = @AcademicYearId

		-- 4th section
		DECLARE @FeePaymentTypeTable TABLE(
		   PaymentTypeId TINYINT,
		   PaymentTypeName NVARCHAR(50)
		  )

		INSERT INTO @FeePaymentTypeTable(PaymentTypeId, PaymentTypeName) VALUES (1,'Cash'),(2,'Cheque'),(3,'DD'),(4,'Credit/Debit Card'),(5,'Net Banking'),(6,'UPI Payment');

		SELECT row_number() over(order by FeePaymentId asc) as InstallmentNumber,
		f.InvoiceNumber,
		f.OnlineTransactionDateTime,
		f.PaidAmount,
		t.PaymentTypeName,
		f.ChequeDate,
		IIF(f.PaymentTypeId = 2 OR f.PaymentTypeId = 3, IIF(f.IsChequeClear = 1, 'Yes', 'No'),'') AS IsChequeOrDDClear,
		IIF(f.PaymentTypeId = 2 OR f.PaymentTypeId = 3, IIF(f.IsChequeClear = 1, f.ChequeNumber, f.ChequeNumber),f.OnlineTransactionId) AS OnlineTransactionId,
		f.FeePaymentId
		FROM FeePayment f
		INNER JOIN @FeePaymentTypeTable t
		ON f.PaymentTypeId = t.PaymentTypeId
		WHERE
			f.IsDeleted <> 1
		AND f.GradeId = @GradeId
		AND f.DivisionId = @DivisionId
		AND f.AcademicYearId = @AcademicYearId
		AND f.StudentId = @StudentId

		--5th section
		SELECT F.DiscountEndDate,
		F.LateFeeStartDate,
		F.FeeWavierTypeId,
		ROW_NUMBER() OVER(partition by F.FeeWavierTypeId order by F.FeeWavierTypesInstallmentsDetailsId, F.FeeWavierTypeId asc) AS InstallmentNumber
		FROM
		FeeWavierTypesInstallmentsDetails F
		WHERE F.IsDeleted <> 1
		AND F.AcademicYearId = @AcademicYearId
		
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