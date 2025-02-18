-- =============================================
-- Author:    Meena Kotkar
-- Create date: 09/04/2024
-- Description:  This stored procedure is used to get Route info in Grid
-- =============================================
CREATE PROCEDURE [dbo].[uspTransportRouteGridSelect](
@AcademicYearId SMALLINT,
@ConsumerName NVARCHAR(150)=NULL) AS BEGIN
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
  R.CoOrdinatorId,
  R.CoOrdinatorRoleId,
  V.VehicleNumber,
  V.RagistrationNumber,
  V.Type,
  V.TotalSeats,
  V.TotalSeats - (SELECT COUNT(tm.ConsumerId) FROM dbo.TransportConsumerStoppageMapping tm 
  INNER JOIN dbo.TransportStoppage ts ON tm.StoppageId = ts.StoppageId AND tm.FromDate <= GETDATE() AND tm.ToDate >= GETDATE()
  WHERE tm.IsDeleted <> 1 AND tm.AcademicYearId = @AcademicYearId AND ts.RouteId = R.RouteId) AS AvailableSeat
    FROM dbo.TransportRoute R
    INNER JOIN dbo.Vehicle V ON V.VehicleId =R.VehicleId
  WHERE
  R.AcademicYearId=@AcademicYearId AND 
    ISNULL(R.IsDeleted,0)<>1 AND V.IsDeleted <> 1
    AND 
    ((@ConsumerName IS NULL OR @ConsumerName='') OR
    EXISTS(SELECT tm.TransportConsumerStoppageMappingId FROM dbo.TransportConsumerStoppageMapping tm 
  INNER JOIN dbo.TransportStoppage ts ON tm.StoppageId = ts.StoppageId 
  LEFT JOIN dbo.[Student] st ON tm.ConsumerId=st.StudentId AND tm.RoleId=5
  LEFT JOIN dbo.[Admin] ad ON tm.ConsumerId=ad.AdminId AND tm.RoleId=2
  LEFT JOIN dbo.Teacher te ON tm.ConsumerId=te.TeacherId AND tm.RoleId=3
  LEFT JOIN dbo.Clerk cl ON tm.ConsumerId=cl.ClerkId AND tm.RoleId=4 
  LEFT JOIN dbo.CabDriver cb ON tm.ConsumerId=cb.CabDriverId AND tm.RoleId=6
  WHERE tm.IsDeleted <> 1 AND ts.IsDeleted<>1 AND tm.AcademicYearId = @AcademicYearId AND ts.RouteId = R.RouteId AND
  CASE WHEN tm.RoleId=5 THEN CONCAT(st.FirstName,' ',st.MiddleName,' ',st.LastName)
       WHEN tm.RoleId=2 THEN CONCAT(ad.FirstName,' ',ad.MiddleName,' ',ad.LastName)
       WHEN tm.RoleId=3 THEN CONCAT(te.FirstName,' ',te.MiddleName,' ',te.LastName)
       WHEN tm.RoleId=4 THEN CONCAT(cl.FirstName,' ',cl.MiddleName,' ',cl.LastName)
       WHEN tm.RoleId=6 THEN CONCAT(cb.FirstName,' ',cb.MiddleName,' ',cb.LastName)
 ELSE '' END LIKE '%'+@ConsumerName+'%' ));

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