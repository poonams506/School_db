CREATE FUNCTION udfConsumerTransportStoppageDiscountedFee (@AcademicYearId SMALLINT, @ConsumerId BIGINT, @RoleId SMALLINT, @TransportConsumerStoppageMappingId INT)
RETURNS MONEY AS
BEGIN

		  DECLARE @AddnDiscFee MONEY = 0;
          
		  SELECT @AddnDiscFee = 
             ISNULL(SUM(feeAddnDisc.AdditionalDiscountedAmount),0)
          FROM 
            TransportFeeAdditionalDiscount feeAddnDisc
          WHERE feeAddnDisc.AcademicYearId = @AcademicYearId AND feeAddnDisc.ConsumerId = @ConsumerId AND feeAddnDisc.RoleId = @RoleId AND feeAddnDisc.IsDeleted <> 1 
          AND feeAddnDisc.TransportConsumerStoppageMappingId = @TransportConsumerStoppageMappingId

		  RETURN @AddnDiscFee

END;