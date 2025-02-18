CREATE PROCEDURE [dbo].[uspConsumerTransportMappingUpsert](
 @Consumers dbo.[TransportConsumerType]  READONLY,
 @UserId INT
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON
  
DECLARE @CurrentDateTime DATETIME = GETDATE();
BEGIN TRY 

MERGE INTO dbo.TransportConsumerStoppageMapping AS Target
	USING
    (SELECT 
	TransportConsumerStoppageMappingId,RoleId,
	ConsumerId,AcademicYearId,FromDate,ToDate,
	PickDropId,PickDropPrice,StoppageId
	FROM @Consumers) AS Source(TransportConsumerStoppageMappingId,RoleId,
							   ConsumerId,AcademicYearId,FromDate,ToDate,
   							   PickDropId,PickDropPrice,StoppageId)
    ON Source.TransportConsumerStoppageMappingId>0 AND Source.TransportConsumerStoppageMappingId=Target.TransportConsumerStoppageMappingId
	WHEN MATCHED THEN 
		UPDATE SET Target.PickDropId=Source.PickDropId,
				   Target.FromDate=Source.FromDate,
				   Target.ToDate=source.ToDate,
				   Target.PickDropPrice=Source.PickDropPrice,
				   Target.StoppageId = Source.StoppageId,
				   Target.ModifiedDate=@CurrentDateTime,
				   Target.ModifiedBy=@UserId
	WHEN NOT MATCHED THEN 
		INSERT(RoleId,
			   ConsumerId,AcademicYearId,FromDate,ToDate,
			   PickDropId,PickDropPrice,StoppageId,CreatedBy,CreatedDate)
	    VALUES(RoleId,
			   ConsumerId,AcademicYearId,FromDate,ToDate,
			   PickDropId,PickDropPrice,StoppageId,@UserId,@CurrentDateTime);



END TRY 
BEGIN CATCH 
DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
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
@ErrorState 
END CATCH 
END