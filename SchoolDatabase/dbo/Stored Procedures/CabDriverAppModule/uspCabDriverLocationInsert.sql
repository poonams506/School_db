-- Author:   Abhishek Kumar
-- Create date: 02/08/2024
-- Description:  This stored procedure is used Update Cab Driver location
-- =============================================
CREATE PROC dbo.uspCabDriverLocationInsert(
  @TripId BIGINT,
  @Lat DECIMAL(18,6),
  @Long DECIMAL(18,6)
)
AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON DECLARE @CurrentDateTime DATETIME = GETDATE();
BEGIN TRY
    
	IF NOT EXISTS (SELECT TOP 1 CabDriverTripCurrentLocationId FROM dbo.CabDriverTripCurrentLocation WHERE TripId = @TripId AND CAST(LastSyncDate AS DATE) = CAST(LastSyncDate AS DATE))
	BEGIN
	    INSERT INTO dbo.CabDriverTripCurrentLocation(TripId,Lat,Long,LastSyncDate)
	    VALUES (@TripId,@Lat,@Long,@CurrentDateTime)
	END
	ELSE
	BEGIN
	    UPDATE dbo.CabDriverTripCurrentLocation SET Lat = @Lat , Long = @Long, LastSyncDate = @CurrentDateTime WHERE TripId = @TripId 
	END
   
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
@ErrorState END CATCH END
GO
