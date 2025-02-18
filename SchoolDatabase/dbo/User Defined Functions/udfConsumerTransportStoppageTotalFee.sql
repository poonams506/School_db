CREATE FUNCTION udfConsumerTransportStoppageTotalFee (@AcademicYearId SMALLINT, @ConsumerId BIGINT, @RoleId SMALLINT, @TransportConsumerStoppageMappingId INT)
RETURNS MONEY AS
BEGIN

          DECLARE @TotalTransportFee MONEY = 0;
          SELECT @TotalTransportFee = ISNULL(SUM(dbo.udfConsumerTransportStoppageTotalFeeByDate(@AcademicYearId, @ConsumerId, @RoleId, F.FromDate, F.ToDate, F.PickDropPrice, F.TransportConsumerStoppageMappingId)),0)
                  FROM TransportConsumerStoppageMapping F
                  WHERE F.AcademicYearId = @AcademicYearId AND F.ConsumerId = @ConsumerId AND F.RoleId = @RoleId AND F.IsDeleted <> 1 AND F.TransportConsumerStoppageMappingId = @TransportConsumerStoppageMappingId;

         
		  RETURN @TotalTransportFee;

END;