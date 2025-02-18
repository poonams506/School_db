-- =============================================
-- Author:    Deepak Walunj
-- Create date: 31/08/2023
-- Description:  This stored procedure is used to get Fee Payment info detail by student Id
-- =============================================
CREATE PROCEDURE [dbo].[uspParentAppTransportFeePaymentSelect]
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


		SELECT 
		dbo.udfConsumerTransportTotalFee(@AcademicYearId, @StudentId, 5) AS 'TotalFee',
		dbo.udfConsumerTransportPaidAmount(@AcademicYearId, @StudentId, 5) AS 'TotalPaid',
		dbo.udfConsumerTransportDueAmount(@AcademicYearId, @StudentId, 5) AS 'TotalDue',
		dbo.udfConsumerTransportDiscountedFee(@AcademicYearId, @StudentId, 5) AS 'TotalDiscount'

		SELECT dbo.udfConsumerTransportStoppageTotalFee(@AcademicYearId, S.StudentId, 5, transport.TransportConsumerStoppageMappingId) AS 'TotalFee',
			 dbo.udfConsumerTransportStoppageDiscountedFee(@AcademicYearId, S.StudentId, 5, transport.TransportConsumerStoppageMappingId) AS 'DiscountedFee',
			 dbo.udfConsumerTransportStoppagePaidAmount(@AcademicYearId, S.StudentId, 5, transport.TransportConsumerStoppageMappingId) AS 'PaidAmount',
			 dbo.udfConsumerTransportStoppageOtherPaidAmount(@AcademicYearId, S.StudentId, 5, transport.TransportConsumerStoppageMappingId) AS 'OtherPaidAmount',
			 dbo.udfConsumerTransportStoppageDueAmount(@AcademicYearId, S.StudentId, 5, transport.TransportConsumerStoppageMappingId) AS 'DueAmount',
			 dbo.udfConsumerTransportStoppageChequeClearedAmount(@AcademicYearId, S.StudentId, 5, transport.TransportConsumerStoppageMappingId) AS 'ChequeClearedAmount',
			 dbo.udfConsumerTransportStoppageChequeUnClearAmount(@AcademicYearId, S.StudentId, 5, transport.TransportConsumerStoppageMappingId) AS 'ChequeUnclearAmount',
			 @StudentId AS ConsumerId, 5 AS RoleId, @AcademicYearId AS AcademicYearId, transport.PickDropId, transport.PickDropPrice, transport.TransportConsumerStoppageMappingId,
			 dbo.udfConsumerTransportStoppageNoOfMonths(@AcademicYearId, @StudentId, 5, transport.FromDate, transport.ToDate, transport.TransportConsumerStoppageMappingId) as Months,
			 format(transport.FromDate, 'MMM-yy') AS FromDateString, format(transport.ToDate, 'MMM-yy') AS ToDateString, 
			 (SELECT tempStoppage.StoppageName FROM TransportStoppage tempStoppage WHERE tempStoppage.StoppageId = transport.StoppageId AND tempStoppage.IsDeleted <> 1 
			 AND tempStoppage.AcademicYearId = @AcademicYearId) AS StoppageName,
			 (SELECT tempRoute.RouteName FROM TransportRoute tempRoute INNER JOIN TransportStoppage tempStoppage ON tempRoute.RouteId = tempStoppage.RouteId
			 WHERE tempStoppage.StoppageId = transport.StoppageId AND tempStoppage.IsDeleted <> 1 AND tempStoppage.AcademicYearId = @AcademicYearId
			 AND tempRoute.IsDeleted <> 1 AND tempRoute.AcademicYearId = @AcademicYearId
			 ) AS RouteName
		  FROM StudentGradeDivisionMapping M
			   INNER JOIN Student S
			   ON M.StudentId = S.StudentId
			   INNER JOIN TransportConsumerStoppageMapping transport
			   ON M.StudentId = transport.ConsumerId AND transport.RoleId = 5 AND transport.AcademicYearId = @AcademicYearId
		  WHERE
		   M.IsDeleted <> 1
		   AND S.IsDeleted <> 1
		   AND S.IsArchive <> 1
		   AND M.StudentId = @StudentId
		   AND M.AcademicYearId = @AcademicYearId
		   AND transport.IsDeleted <> 1
		   AND transport.AcademicYearId = @AcademicYearId

		-- 3rd section
		
		DECLARE @FeePaymentTypeTable TABLE(
		   PaymentTypeId TINYINT,
		   PaymentTypeName NVARCHAR(50)
		  )

		INSERT INTO @FeePaymentTypeTable(PaymentTypeId, PaymentTypeName) VALUES (1,'Cash'),(2,'Cheque'),(3,'DD'),(4,'Credit/Debit Card'),(5,'Net Banking'),(6,'UPI Payment');

		SELECT row_number() over(order by TransportFeePaymentId asc) as InstallmentNumber,
		f.InvoiceNumber,
		f.OnlineTransactionDateTime,
		f.PaidAmount,
		t.PaymentTypeName,
		f.ChequeDate,
		IIF(f.PaymentTypeId = 2 OR f.PaymentTypeId = 3, IIF(f.IsChequeClear = 1, 'Yes', 'No'),'') AS IsChequeOrDDClear,
		IIF(f.PaymentTypeId = 2 OR f.PaymentTypeId = 3, IIF(f.IsChequeClear = 1, f.ChequeNumber, f.ChequeNumber),f.OnlineTransactionId) AS OnlineTransactionId,
		f.TransportFeePaymentId
		FROM TransportFeePayment f
		INNER JOIN @FeePaymentTypeTable t
		ON f.PaymentTypeId = t.PaymentTypeId
		WHERE
			f.IsDeleted <> 1
		AND f.RoleId = 5
		AND f.AcademicYearId = @AcademicYearId
		AND f.ConsumerId = @StudentId
		
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