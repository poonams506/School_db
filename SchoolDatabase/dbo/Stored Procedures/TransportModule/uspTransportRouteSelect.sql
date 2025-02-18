-- =============================================
-- Author:    Meena Kotkar
-- Create date: 09/04/2024
-- Description:  This stored procedure is used to get Route info 
-- =============================================
CREATE PROCEDURE [dbo].[uspTransportRouteSelect](
@RouteId BIGINT,
@AcademicYearId SMALLINT
) AS Begin
SET
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET
  NOCOUNT ON;
BEGIN TRY                
 SELECT 
  R.RouteId,
  R.RouteName,
  R.FirstPickUpTime,
  R.LastPickUpTime,
  R.VehicleId,
  R.SharedRouteId,
  R.IsSharedVehicle,
  R.CoOrdinatorId,
  R.CoOrdinatorRoleId,
  V.VehicleNumber,
  V.RagistrationNumber,
  V.Type,
  V.TotalSeats
    FROM TransportRoute R
    LEFT JOIN Vehicle V ON R.VehicleId =V.VehicleId
  WHERE
  R.AcademicYearId=@AcademicYearId AND R.RouteId=@RouteId AND 
    ISNULL(R.IsDeleted,0)<>1 AND V.IsDeleted <> 1
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
@ErrorState END CATCH End