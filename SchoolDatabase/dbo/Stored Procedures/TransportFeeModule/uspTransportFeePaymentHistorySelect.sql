-- =============================================
-- Author:    Deepak Walunj
-- Create date: 17/09/2023
-- Description:  This stored procedure is used to get Fee Payment history info detail by payment fee Id
-- =============================================
CREATE PROCEDURE [dbo].[uspTransportFeePaymentHistorySelect]
	@AcademicYearId SMALLINT,
	@ConsumerId BIGINT,
	@TransportConsumerStoppageMappingId INT,
	@RoleId INT,
	@TransportFeePaymentId BIGINT
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
		IF @RoleId = 5 -- student
		BEGIN
        SELECT 
		s.FirstName + ' ' + s.MiddleName + ' ' + s.LastName AS 'FullName',
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
		ON m.GradeId = g.GradeId
		INNER JOIN Division d
		ON m.DivisionId = d.DivisionId
		INNER JOIN TransportFeePayment p
		ON p.ConsumerId = s.StudentId AND p.RoleId = @RoleId AND p.AcademicYearId = m.AcademicYearId AND p.TransportFeePaymentId = @TransportFeePaymentId AND p.TransportConsumerStoppageMappingId = @TransportConsumerStoppageMappingId
		INNER JOIN @FeePaymentTypeTable t
        ON p.PaymentTypeId = t.PaymentTypeId 
		WHERE ISNULL(s.IsDeleted,0) <> 1
		AND ISNULL(m.IsDeleted,0) <> 1
		AND s.IsArchive <> 1
		AND ISNULL(g.IsDeleted,0) <> 1
		AND ISNULL(d.IsDeleted,0) <> 1
		AND ISNULL(p.IsDeleted,0) <> 1
		AND m.AcademicYearId = @AcademicYearId
		AND m.StudentId = @ConsumerId
		AND p.AcademicYearId = @AcademicYearId
		AND p.ConsumerId = @ConsumerId
		AND p.TransportConsumerStoppageMappingId = @TransportConsumerStoppageMappingId
		AND p.RoleId = @RoleId
		END
		IF @RoleId = 3 -- teacher
		BEGIN
		    SELECT 
		t.FirstName + ' ' + t.MiddleName + ' ' + t.LastName AS 'FullName',
		p.AcademicYearId,
        (SELECT SchoolName FROM School) AS SchoolName,
		(SELECT ISNULL(SchoolAddressLine1,'') + IIF(SchoolAddressLine1 IS NULL,'',', ') + ISNULL(SchoolAddressLine2,'') + IIF(SchoolAddressLine2 IS NULL,'',', ') + TalukaName + ', ' + DistrictName + ', ' + StateName + ', ' + Pincode  FROM School) AS SchoolAddress,
		IIF(p.PaymentTypeId = 2 OR p.PaymentTypeId = 3, p.ChequeNumber, p.OnlineTransactionId) AS TransactionId,
		p.InvoiceNumber,
		pt.PaymentTypeName,
		p.OnlineTransactionDateTime AS PaymentDate,
		p.ChequeDate AS ChequeDate,
		p.ChequeBank AS ChequeBank
		FROM Teacher t
		INNER JOIN TransportFeePayment p
		ON p.ConsumerId = t.TeacherId AND p.RoleId = @RoleId AND p.AcademicYearId = @AcademicYearId AND p.TransportFeePaymentId = @TransportFeePaymentId AND p.TransportConsumerStoppageMappingId = @TransportConsumerStoppageMappingId
		INNER JOIN @FeePaymentTypeTable pt
        ON p.PaymentTypeId = pt.PaymentTypeId 
		WHERE ISNULL(t.IsDeleted,0) <> 1
		AND ISNULL(p.IsDeleted,0) <> 1
		AND p.AcademicYearId = @AcademicYearId
		AND p.ConsumerId = @ConsumerId
		AND p.RoleId = @RoleId
		AND p.TransportConsumerStoppageMappingId = @TransportConsumerStoppageMappingId
		END
		IF @RoleId = 4 -- Clerk
		BEGIN
		    SELECT 
		t.FirstName + ' ' + t.MiddleName + ' ' + t.LastName AS 'FullName',
		p.AcademicYearId,
        (SELECT SchoolName FROM School) AS SchoolName,
		(SELECT ISNULL(SchoolAddressLine1,'') + IIF(SchoolAddressLine1 IS NULL,'',', ') + ISNULL(SchoolAddressLine2,'') + IIF(SchoolAddressLine2 IS NULL,'',', ') + TalukaName + ', ' + DistrictName + ', ' + StateName + ', ' + Pincode  FROM School) AS SchoolAddress,
		IIF(p.PaymentTypeId = 2 OR p.PaymentTypeId = 3, p.ChequeNumber, p.OnlineTransactionId) AS TransactionId,
		p.InvoiceNumber,
		pt.PaymentTypeName,
		p.OnlineTransactionDateTime AS PaymentDate,
		p.ChequeDate AS ChequeDate,
		p.ChequeBank AS ChequeBank
		FROM Clerk t
		INNER JOIN TransportFeePayment p
		ON p.ConsumerId = t.ClerkId AND p.RoleId = @RoleId AND p.AcademicYearId = @AcademicYearId AND p.TransportFeePaymentId = @TransportFeePaymentId AND p.TransportConsumerStoppageMappingId = @TransportConsumerStoppageMappingId
		INNER JOIN @FeePaymentTypeTable pt
        ON p.PaymentTypeId = pt.PaymentTypeId 
		WHERE ISNULL(t.IsDeleted,0) <> 1
		AND ISNULL(p.IsDeleted,0) <> 1
		AND p.AcademicYearId = @AcademicYearId
		AND p.ConsumerId = @ConsumerId
		AND p.RoleId = @RoleId
		 AND p.TransportConsumerStoppageMappingId = @TransportConsumerStoppageMappingId
		END
		IF @RoleId = 6 -- Cab Driver
		BEGIN
		    SELECT 
		t.FirstName + ' ' + t.MiddleName + ' ' + t.LastName AS 'FullName',
		p.AcademicYearId,
        (SELECT SchoolName FROM School) AS SchoolName,
		(SELECT ISNULL(SchoolAddressLine1,'') + IIF(SchoolAddressLine1 IS NULL,'',', ') + ISNULL(SchoolAddressLine2,'') + IIF(SchoolAddressLine2 IS NULL,'',', ') + TalukaName + ', ' + DistrictName + ', ' + StateName + ', ' + Pincode  FROM School) AS SchoolAddress,
		IIF(p.PaymentTypeId = 2 OR p.PaymentTypeId = 3, p.ChequeNumber, p.OnlineTransactionId) AS TransactionId,
		p.InvoiceNumber,
		pt.PaymentTypeName,
		p.OnlineTransactionDateTime AS PaymentDate,
		p.ChequeDate AS ChequeDate,
		p.ChequeBank AS ChequeBank
		FROM CabDriver t
		INNER JOIN TransportFeePayment p
		ON p.ConsumerId = t.CabDriverId AND p.RoleId = @RoleId AND p.AcademicYearId = @AcademicYearId AND p.TransportFeePaymentId = @TransportFeePaymentId AND p.TransportConsumerStoppageMappingId = @TransportConsumerStoppageMappingId
		INNER JOIN @FeePaymentTypeTable pt
        ON p.PaymentTypeId = pt.PaymentTypeId 
		WHERE ISNULL(t.IsDeleted,0) <> 1
		AND ISNULL(p.IsDeleted,0) <> 1
		AND p.AcademicYearId = @AcademicYearId
		AND p.ConsumerId = @ConsumerId
		AND p.RoleId = @RoleId
		 AND p.TransportConsumerStoppageMappingId = @TransportConsumerStoppageMappingId
		END

		--2nd result for Particulars
		DECLARE @InstallmentPaidTable TABLE(
		FeeAfterDiscount MONEY,
		PaidAmount MONEY
		)
		INSERT INTO @InstallmentPaidTable
		SELECT 
		ISNULL(d.FeeAfterDiscount,0) AS 'FeeAfterDiscount',
		ISNULL(d.PaidAmount,0) AS 'PaidAmount'
		FROM 
		TransportFeePaymentDetails d
		WHERE d.ConsumerId = @ConsumerId AND d.RoleId = @RoleId AND d.AcademicYearId = @AcademicYearId AND d.TransportFeePaymentId = @TransportFeePaymentId AND d.TransportConsumerStoppageMappingId = @TransportConsumerStoppageMappingId
		AND ISNULL(d.IsDeleted,0) <> 1
		AND d.AcademicYearId = @AcademicYearId
		AND d.RoleId= @RoleId
		AND d.ConsumerId = @ConsumerId
		AND d.TransportConsumerStoppageMappingId = @TransportConsumerStoppageMappingId
		AND d.TransportFeePaymentId = @TransportFeePaymentId

		DECLARE @InstallmentAlreadyPaidTable TABLE(
		AlreadyPaid MONEY
		)
		INSERT INTO @InstallmentAlreadyPaidTable
		SELECT 
		ISNULL(SUM(d.PaidAmount),0) AS 'AlreadyPaid'
		FROM 
		TransportFeePaymentDetails d
		WHERE d.ConsumerId = @ConsumerId AND d.RoleId = @RoleId AND d.AcademicYearId = @AcademicYearId AND d.TransportFeePaymentId < @TransportFeePaymentId AND d.TransportConsumerStoppageMappingId = @TransportConsumerStoppageMappingId
		AND ISNULL(d.IsDeleted,0) <> 1
		AND d.AcademicYearId = @AcademicYearId
		AND d.RoleId= @RoleId
		AND d.ConsumerId = @ConsumerId
		AND d.TransportConsumerStoppageMappingId = @TransportConsumerStoppageMappingId
		AND d.TransportFeePaymentId < @TransportFeePaymentId


		SELECT
		dbo.udfConsumerTransportStoppageTotalFee(@AcademicYearId, @ConsumerId, @RoleId, @TransportConsumerStoppageMappingId) AS 'TotalFee',
		(SELECT FeeAfterDiscount FROM @InstallmentPaidTable) AS FeeAfterDiscount,
		(SELECT PaidAmount FROM @InstallmentPaidTable) AS PaidAmount,
		ISNULL((SELECT AlreadyPaid FROM @InstallmentAlreadyPaidTable),0) AS AlreadyPaid,
		ISNULL((SELECT FeeAfterDiscount FROM @InstallmentPaidTable) - ((SELECT PaidAmount FROM @InstallmentPaidTable) + ISNULL((SELECT AlreadyPaid FROM @InstallmentAlreadyPaidTable),0)),0) AS DueAmount

		SELECT a.months
		FROM (VALUES(1,'Jan'),(2,'Feb'),(3,'Mar'),(4,'Apr'),(5,'May'),(6,'Jun'),(7,'Jul'),
               (8,'Aug'),(9,'Sep'),(10,'Oct'),(11,'Nov'),(12,'Dec')) a(number,months)
		INNER JOIN TransportFeePaymentAppliedMonthMapping m 
		ON m.MonthMasterId = a.number
		WHERE m.AcademicYearId = @AcademicYearId AND m.ConsumerId = @ConsumerId AND m.IsDeleted <> 1
		AND m.RoleId = @RoleId AND m.TransportConsumerStoppageMappingId = @TransportConsumerStoppageMappingId AND m.TransportFeePaymentId = @TransportFeePaymentId
		
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