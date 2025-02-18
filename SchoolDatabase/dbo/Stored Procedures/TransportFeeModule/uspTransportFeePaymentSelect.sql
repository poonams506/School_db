-- =============================================
-- Author:    Deepak Walunj
-- Create date: 31/08/2023
-- Description:  This stored procedure is used to get Fee Payment info detail by student Id
-- =============================================
CREATE PROCEDURE [dbo].[uspTransportFeePaymentSelect]
	@ConsumerId BIGINT,
	@TransportConsumerStoppageMappingId INT,
	@AcademicYearId SMALLINT,
	@RoleId INT
AS BEGIN
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 
        
               -- 1st result for student info
		IF @RoleId = 5 -- student
		BEGIN
        SELECT 
		s.FirstName + ' ' + s.MiddleName + ' ' + s.LastName AS 'FullName',
		s.GeneralRegistrationNo,
		s.IsNewStudent,
		m.IsRTEStudent,
		s.AppAccessMobileNo,
		m.AcademicYearId,
		m.RollNumber,
		g.GradeName,
		d.DivisionName
		FROM Student s
		INNER JOIN StudentGradeDivisionMapping m
		ON s.StudentId = m.StudentId
		INNER JOIN Grade g
		ON m.GradeId = g.GradeId
		INNER JOIN Division d
		ON m.DivisionId = d.DivisionId
		WHERE ISNULL(s.IsDeleted,0) <> 1
		AND ISNULL(s.IsArchive,0) <> 1
		AND ISNULL(m.IsDeleted,0) <> 1
		AND ISNULL(g.IsDeleted,0) <> 1
		AND ISNULL(d.IsDeleted,0) <> 1
		AND m.AcademicYearId = @AcademicYearId
		AND m.StudentId = @ConsumerId
		END
		IF @RoleId = 3 -- teacher
		BEGIN
		    SELECT FirstName + ' ' + MiddleName + ' ' + LastName AS 'FullName',
			MobileNumber as 'AppAccessMobileNo',
			@AcademicYearId As AcademicYearId
			FROM Teacher
			WHERE TeacherId = @ConsumerId AND IsDeleted <> 1
		END
		IF @RoleId = 4 -- Clerk
		BEGIN
		    SELECT FirstName + ' ' + MiddleName + ' ' + LastName AS 'FullName',
			MobileNumber as 'AppAccessMobileNo',
			@AcademicYearId As AcademicYearId
			FROM Clerk
			WHERE ClerkId = @ConsumerId AND IsDeleted <> 1
		END
		IF @RoleId = 6 -- Cab Driver
		BEGIN
		    SELECT FirstName + ' ' + MiddleName + ' ' + LastName AS 'FullName',
			MobileNumber as 'AppAccessMobileNo',
			@AcademicYearId As AcademicYearId
			FROM CabDriver
			WHERE CabDriverId = @ConsumerId AND IsDeleted <> 1
		END

		-- 2nd result for Month Mapping
		SELECT DISTINCT
		m.AcademicYearId,
		m.MonthMasterId,
		m.TransportFeeAdditionalDiscountId
		FROM 
		TransportFeePaymentAppliedMonthMapping m
		INNER JOIN TransportFeePayment p
		ON m.TransportFeePaymentId = p.TransportFeePaymentId AND m.RoleId = p.RoleId AND m.ConsumerId = p.ConsumerId AND m.AcademicYearId = p.AcademicYearId AND m.TransportConsumerStoppageMappingId = p.TransportConsumerStoppageMappingId
		WHERE ISNULL(p.IsDeleted,0) <> 1
		AND ISNULL(m.IsDeleted,0) <> 1
		AND m.AcademicYearId = @AcademicYearId
		AND p.AcademicYearId = @AcademicYearId
		AND m.ConsumerId = @ConsumerId
		AND p.ConsumerId = @ConsumerId
		AND m.RoleId = @RoleId
		AND p.RoleId = @RoleId
		AND m.TransportConsumerStoppageMappingId = @TransportConsumerStoppageMappingId
		AND p.TransportConsumerStoppageMappingId = @TransportConsumerStoppageMappingId

		-- 3rd result for Additional Discount
		SELECT DISTINCT
		dbo.udfConsumerTransportTotalFee(@AcademicYearId, @ConsumerId, @RoleId) AS 'TotalFee',
		a.TransportFeeAdditionalDiscountId,
		a.AcademicYearId,
		a.AdditionalDiscountedAmount,
		a.InstallmentPaybleFee,
		a.AdditionalDiscountedRemark,
		(SELECT Count(TransportFeePaymentId) FROM TransportFeePayment
		WHERE AcademicYearId = @AcademicYearId AND IsDeleted <> 1 AND RoleId = @RoleId AND TransportConsumerStoppageMappingId = @TransportConsumerStoppageMappingId AND ConsumerId = @ConsumerId AND TransportFeePaymentId <= a.TransportFeePaymentId) AS 'PaymentInstallmentNumber',
		CONVERT(NVARCHAR(30), a.CreatedDate, 103)  AS 'AppliedDate'
		FROM 
		TransportFeeAdditionalDiscount a
		INNER JOIN TransportFeePayment p
		ON a.TransportFeePaymentId = a.TransportFeePaymentId AND a.AcademicYearId = p.AcademicYearId AND a.ConsumerId = p.ConsumerId AND a.RoleId = p.RoleId AND a.TransportConsumerStoppageMappingId = p.TransportConsumerStoppageMappingId
		WHERE ISNULL(p.IsDeleted,0) <> 1
		AND ISNULL(a.IsDeleted,0) <> 1
		AND a.AcademicYearId = @AcademicYearId
		AND p.AcademicYearId = @AcademicYearId
		AND a.ConsumerId = @ConsumerId
		AND p.ConsumerId = @ConsumerId
		AND a.RoleId = @RoleId
		AND p.RoleId = @RoleId
		AND a.TransportConsumerStoppageMappingId = @TransportConsumerStoppageMappingId
		AND p.TransportConsumerStoppageMappingId = @TransportConsumerStoppageMappingId

		-- 4th result for Particulars
		SELECT 
		dbo.udfConsumerTransportStoppageTotalFee(@AcademicYearId, @ConsumerId, @RoleId, @TransportConsumerStoppageMappingId) AS 'TotalFee',
		dbo.udfConsumerTransportStoppagePaidAmount(@AcademicYearId, @ConsumerId, @RoleId, @TransportConsumerStoppageMappingId) AS 'AlreadyPaid',
		(SELECT ISNULL(SUM(d.AdditionalDiscAmount),0)
		FROM
		TransportFeePaymentDetails d
		WHERE d.ConsumerId = @ConsumerId AND d.AcademicYearId = @AcademicYearId AND d.IsDeleted <> 1 
		AND d.RoleId = @RoleId AND d.TransportConsumerStoppageMappingId = @TransportConsumerStoppageMappingId) AS 'AdditionalDiscAmount'

		
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