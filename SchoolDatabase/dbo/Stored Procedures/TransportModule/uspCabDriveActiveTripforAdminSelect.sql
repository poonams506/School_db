-- =============================================
-- Author:    Shambala Apugade
-- Create date: 29/08/2024
-- Description:  This stored procedure returns Active Trip for Admin.
-- =============================================


CREATE PROCEDURE [dbo].[uspCabDriveActiveTripforAdminSelect]
	@AcademicYearId INT
	AS Begin
SET
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET
  NOCOUNT ON;
   DECLARE @CurrentDate DATE = CAST(GETDATE() AS DATE);
BEGIN TRY  

WITH CTE AS

(SELECT CabDriverTripCurrentLocationId, TripId, Lat, Long, ROW_NUMBER() OVER (PARTITION BY TRIPID ORDER BY CabDriverTripCurrentLocationId DESC)
AS rn FROM CabDriverTripCurrentLocation c WHERE CAST(c.LastSyncDate AS DATE) = @CurrentDate)

SELECT c.CabDriverTripCurrentLocationId,t.TripId,c.Lat, c.Long, r.RouteId,r.RouteName,r.VehicleId,v.VehicleNumber, v.RagistrationNumber
FROM CTE c 
INNER JOIN Trip t ON t.TripId = c.TripId
INNER JOIN TransportRoute r ON r.RouteId =t.RouteId
INNER JOIN Vehicle v ON r.VehicleId = v.VehicleId


WHERE rn =1 AND t.TripEndTime IS NULL AND r.AcademicYearId =@AcademicYearId
AND t.IsDeleted <> 1 AND v.IsDeleted <>1 AND r.IsDeleted <>1 
AND  CAST(t.CreatedDate AS DATE) = @CurrentDate

END TRY 
BEGIN CATCH
DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
DECLARE @ErrorState INT = ERROR_STATE();
DECLARE @ErrorNumber INT = ERROR_NUMBER();
DECLARE @ErrorLine INT = ERROR_LINE();
DECLARE @ErrorProcedure NVARCHAR(1000) = ERROR_PROCEDURE();
EXEC uspExceptionLogInsert 
@ErrorLine, 
@ErrorMessage, 
@ErrorNumber, 
@ErrorProcedure, 
@ErrorSeverity,
@ErrorState;
END CATCH;
END;




 

