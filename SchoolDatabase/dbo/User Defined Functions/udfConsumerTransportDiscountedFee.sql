CREATE FUNCTION udfConsumerTransportDiscountedFee (@AcademicYearId SMALLINT, @ConsumerId BIGINT, @RoleId SMALLINT)
RETURNS MONEY AS
BEGIN

		  DECLARE @AddnDiscFee MONEY = 0;
          
		  SELECT @AddnDiscFee = 
             ISNULL(SUM(feeAddnDisc.AdditionalDiscountedAmount),0)
          FROM 
            TransportFeeAdditionalDiscount feeAddnDisc
          WHERE feeAddnDisc.AcademicYearId = @AcademicYearId AND feeAddnDisc.ConsumerId = @ConsumerId AND feeAddnDisc.RoleId = @RoleId AND feeAddnDisc.IsDeleted <> 1 

		  RETURN @AddnDiscFee

END;