CREATE FUNCTION udfConsumerTransportChequeUnClearAmount (@AcademicYearId SMALLINT, @ConsumerId BIGINT, @RoleId SMALLINT)
RETURNS MONEY AS
BEGIN
          DECLARE @TotalFee MONEY;
          SELECT @TotalFee = ISNULL(SUM(feeDetailChequeCleared.PaidAmount),0)
          FROM  TransportFeePaymentDetails feeDetailChequeCleared
          WHERE feeDetailChequeCleared.ConsumerId = @ConsumerId AND feeDetailChequeCleared.AcademicYearId = @AcademicYearId AND 
          feeDetailChequeCleared.RoleId = @RoleId AND (feeDetailChequeCleared.PaymentTypeId = 2 OR feeDetailChequeCleared.PaymentTypeId = 3) AND ISNULL(feeDetailChequeCleared.IsChequeClear,0) = 0
          AND feeDetailChequeCleared.IsDeleted <> 1
		  RETURN @TotalFee

END;