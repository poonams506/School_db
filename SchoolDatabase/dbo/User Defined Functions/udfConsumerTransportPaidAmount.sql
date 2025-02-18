CREATE FUNCTION udfConsumerTransportPaidAmount (@AcademicYearId SMALLINT, @ConsumerId BIGINT, @RoleId SMALLINT)
RETURNS MONEY AS
BEGIN
          

          DECLARE @TotalFee MONEY = 0;
          
                    SELECT @TotalFee = ISNULL(SUM(feeDetail.PaidAmount),0)
                    FROM TransportFeePaymentDetails feeDetail 
                    WHERE feeDetail.ConsumerId = @ConsumerId AND feeDetail.RoleId = @RoleId AND feeDetail.AcademicYearId = @AcademicYearId
                    AND feeDetail.IsDeleted <> 1

          
		  RETURN @TotalFee

END;