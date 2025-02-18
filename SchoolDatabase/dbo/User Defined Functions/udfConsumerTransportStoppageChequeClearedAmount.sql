CREATE FUNCTION udfConsumerTransportStoppageChequeClearedAmount (@AcademicYearId SMALLINT, @ConsumerId BIGINT, @RoleId SMALLINT, @TransportConsumerStoppageMappingId INT)
RETURNS MONEY AS
BEGIN
          DECLARE @TotalFee MONEY;
          SELECT @TotalFee = ISNULL(SUM(feeDetailChequeCleared.PaidAmount),0)
          FROM  TransportFeePaymentDetails feeDetailChequeCleared
          WHERE feeDetailChequeCleared.ConsumerId = @ConsumerId AND feeDetailChequeCleared.AcademicYearId = @AcademicYearId AND feeDetailChequeCleared.TransportConsumerStoppageMappingId = @TransportConsumerStoppageMappingId AND
          feeDetailChequeCleared.RoleId = @RoleId AND (feeDetailChequeCleared.PaymentTypeId = 2 OR feeDetailChequeCleared.PaymentTypeId = 3) AND ISNULL(feeDetailChequeCleared.IsChequeClear,0) = 1
          AND feeDetailChequeCleared.IsDeleted <> 1
		  RETURN @TotalFee

END;