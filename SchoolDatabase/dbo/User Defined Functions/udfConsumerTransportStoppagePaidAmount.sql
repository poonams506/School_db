CREATE FUNCTION udfConsumerTransportStoppagePaidAmount (@AcademicYearId SMALLINT, @ConsumerId BIGINT, @RoleId SMALLINT, @TransportConsumerStoppageMappingId INT)
RETURNS MONEY AS
BEGIN
          

          DECLARE @TotalFee MONEY = 0;
          
                    SELECT @TotalFee = ISNULL(SUM(feeDetail.PaidAmount),0)
                    FROM TransportFeePaymentDetails feeDetail 
                    WHERE feeDetail.ConsumerId = @ConsumerId AND feeDetail.RoleId = @RoleId AND feeDetail.AcademicYearId = @AcademicYearId
                    AND feeDetail.IsDeleted <> 1 AND feeDetail.TransportConsumerStoppageMappingId = @TransportConsumerStoppageMappingId

          
		  RETURN @TotalFee

END;