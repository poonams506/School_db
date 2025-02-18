CREATE FUNCTION udfConsumerTransportDueAmount (@AcademicYearId SMALLINT, @ConsumerId BIGINT, @RoleId SMALLINT)
RETURNS MONEY AS
BEGIN
          DECLARE @TotalFee MONEY;
          SET @TotalFee = ISNULL(dbo.udfConsumerTransportTotalFee(@AcademicYearId,@ConsumerId,@RoleId)
            - dbo.udfConsumerTransportDiscountedFee(@AcademicYearId,@ConsumerId,@RoleId)
            - dbo.udfConsumerTransportPaidAmount(@AcademicYearId,@ConsumerId,@RoleId),0)
          
		  RETURN @TotalFee

END;