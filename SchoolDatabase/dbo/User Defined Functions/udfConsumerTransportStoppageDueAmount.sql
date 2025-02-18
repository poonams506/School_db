CREATE FUNCTION udfConsumerTransportStoppageDueAmount (@AcademicYearId SMALLINT, @ConsumerId BIGINT, @RoleId SMALLINT, @TransportConsumerStoppageMappingId INT)
RETURNS MONEY AS
BEGIN
          DECLARE @TotalFee MONEY;
          SET @TotalFee = ISNULL(dbo.udfConsumerTransportStoppageTotalFee(@AcademicYearId,@ConsumerId,@RoleId, @TransportConsumerStoppageMappingId)
            - dbo.udfConsumerTransportStoppageDiscountedFee(@AcademicYearId,@ConsumerId,@RoleId, @TransportConsumerStoppageMappingId)
            - dbo.udfConsumerTransportStoppagePaidAmount(@AcademicYearId,@ConsumerId,@RoleId, @TransportConsumerStoppageMappingId),0)
          
		  RETURN @TotalFee

END;