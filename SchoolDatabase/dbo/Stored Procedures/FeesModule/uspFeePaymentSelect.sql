-- =============================================
-- Author:    Deepak Walunj
-- Create date: 31/08/2023
-- Description:  This stored procedure is used to get Fee Payment info detail by student Id
-- =============================================
CREATE PROCEDURE [dbo].[uspFeePaymentSelect]
	@StudentId BIGINT,
	@AcademicYearId SMALLINT,
	@GradeId SMALLINT,
	@DivisionId SMALLINT
AS BEGIN
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 
        
               -- 1st result for student info
        SELECT 
		s.FirstName + ' ' + s.MiddleName + ' ' + s.LastName AS 'FullName',
		s.GeneralRegistrationNo,
		s.IsNewStudent,
		s.PreviousAcademicYearPendingFeeAmount,
		m.IsRTEStudent,
		m.ConsationAmount,
		m.IsConsationApplicable,
		s.AppAccessMobileNo,
		m.AcademicYearId,
		m.RollNumber,
		g.GradeName,
		d.DivisionName,
		(SELECT Count(FeePaymentId) FROM FeePayment
		WHERE AcademicYearId = m.AcademicYearId AND IsDeleted <> 1 AND StudentId = M.StudentId AND GradeId = M.GradeId AND DivisionId = M.DivisionId) AS 'PaymentInstallmentDone',
		(SELECT Count(FeePaymentId) FROM FeePayment
		WHERE AcademicYearId = m.AcademicYearId AND IsDeleted <> 1 AND StudentId = M.StudentId AND GradeId = M.GradeId AND DivisionId = M.DivisionId AND SkipDiscount = 1) AS 'SkipDiscountCount'
		FROM Student s
		INNER JOIN StudentGradeDivisionMapping m
		ON s.StudentId = m.StudentId
		INNER JOIN Grade g
		ON m.GradeId = m.GradeId
		INNER JOIN Division d
		ON m.DivisionId = d.DivisionId
		WHERE ISNULL(s.IsDeleted,0) <> 1
		AND ISNULL(s.IsArchive,0) <> 1
		AND ISNULL(m.IsDeleted,0) <> 1
		AND ISNULL(g.IsDeleted,0) <> 1
		AND ISNULL(d.IsDeleted,0) <> 1
		AND m.AcademicYearId = @AcademicYearId
		AND m.StudentId = @StudentId
		AND m.GradeId = @GradeId
		AND m.DivisionId = @DivisionId
		AND g.GradeId = @GradeId
		AND d.DivisionId = @DivisionId

		-- 2nd result for Discount Fee
		SELECT DISTINCT
		m.AcademicYearId,
		m.FeeParticularWavierMappingId
		FROM 
		FeePaymentAppliedWavierMapping m
		INNER JOIN FeePayment p
		ON m.FeePaymentId = p.FeePaymentId
		WHERE ISNULL(p.IsDeleted,0) <> 1
		AND ISNULL(m.IsDeleted,0) <> 1
		AND m.AcademicYearId = @AcademicYearId
	    AND p.StudentId = @StudentId
		AND p.AcademicYearId = @AcademicYearId

		-- 3rd result for Additional Discount
		SELECT DISTINCT
		dbo.udfStudentTotalFee(@GradeId, @DivisionId, @AcademicYearId, @StudentId) AS 'TotalFee',
		a.FeeAdditionalDiscountId,
		a.AcademicYearId,
		a.AdditionalDiscountedAmount,
		a.InstallmentPaybleFee,
		a.AdditionalDiscountedRemark,
		a.FeePaymentId,
		(SELECT Count(FeePaymentId) FROM FeePayment
		WHERE AcademicYearId = @AcademicYearId AND IsDeleted <> 1 AND StudentId = @StudentId AND FeePaymentId <= a.FeePaymentId) AS 'PaymentInstallmentNumber',
		CONVERT(NVARCHAR(30), a.CreatedDate, 103)  AS 'AppliedDate'
		FROM 
		FeeAdditionalDiscount a
		INNER JOIN FeePayment p
		ON a.FeePaymentId = a.FeePaymentId AND a.AcademicYearId = @AcademicYearId AND ISNULL(a.IsDeleted,0) <> 1 AND a.StudentId = p.StudentId
		WHERE ISNULL(p.IsDeleted,0) <> 1
	    AND p.StudentId = @StudentId
		AND p.AcademicYearId = @AcademicYearId
		AND a.IsDeleted <> 1

		-- 4th result for Particulars
		SELECT 
		f.FeeParticularId,
		f.ParticularName,
		f.IsDiscountApplicable,
		ISNULL(f.Amount,0) AS 'TotalFee',
		ISNULL(SUM(d.PaidAmount),0) AS 'AlreadyPaid',
		ISNULL(SUM(d.AdditionalDiscAmount),0) AS 'AdditionalDiscAmount'
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
		ISNULL(SUM(d.PaidAmount),0) AS 'AlreadyPaid',
		ISNULL(SUM(d.AdditionalDiscAmount),0) AS 'AdditionalDiscAmount'
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



		SELECT
             fp.FeeWavierTypesInstallmentsDetailsId
		FROM
			 FeePayment fp
		WHERE 
			 fp.GradeId = @GradeId 
			 AND fp.DivisionId = @DivisionId
			 AND fp.AcademicYearId = @AcademicYearId
			 AND fp.StudentId = @StudentId
			 AND fp.IsDeleted <> 1

		
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