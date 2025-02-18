

 -- =============================================
 -- Author:    Shambala Apugade
 -- Create date: 18/06/2024
 -- Description:  This stored procedure is used to get Route info 
 -- =============================================
 CREATE PROC dbo.uspCabDriverTripUpsert(
 @TripId BIGINT,
 @RouteId BIGINT,
 @TripType NVARCHAR(10),
 @UserId INT,
 @IsTripEnd BIT
 
 ) AS Begin
 SET
   TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
 SET
   NOCOUNT ON DECLARE @CurrentDateTime DATETIME = GETDATE();
 BEGIN TRY 
 
 DECLARE @CurrentTripId BIGINT;
 IF @IsTripEnd=1 
 BEGIN
 		UPDATE dbo.Trip
 			SET
 			[TripEndTime] = @CurrentDateTime,
 			[ModifiedBy] = @UserId, 
 			[ModifiedDate] = @CurrentDateTime
 			WHERE 
 			TripId =@TripId;

 		SET @CurrentTripId=@TripId;
        UPDATE dbo.TripDetail SET DropOffDateTime = GETDATE() WHERE TripId = @TripId AND CAST( PickUpDateTime AS DATE) = CAST(GETDATE() AS DATE)
 END
 ELSE
 BEGIN
     SELECT TOP (1) @CurrentTripId=tr.TripId FROM  dbo.Trip tr WHERE tr.RouteId=@RouteId 
 	AND tr.TripType = @TripType AND tr.TripEndTime IS NULL
 			AND CAST(tr.TripStartTime AS DATE) = CAST(GETDATE() AS DATE) 
 			AND tr.TripEndTime IS NULL ORDER BY tr.TripId DESC
     
 	IF @CurrentTripId IS NULL
 	BEGIN
 	    --INSERT Statement
 		INSERT INTO dbo.Trip
 		([RouteId],[TripStartTime],[TripType] ,[CreatedBy],[CreatedDate]) 
 		VALUES 
 		(@RouteId,@CurrentDateTime,@TripType,@UserId,@CurrentDateTime)
		SET @CurrentTripId=SCOPE_IDENTITY();
 	END
 	
 	
     
 END
 
 SELECT @CurrentTripId;
  
 END TRY BEGIN CATCH DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
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
 @ErrorState END CATCH END
 GO
 

