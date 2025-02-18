-- =============================================
-- Author:    Shambala Apugade
-- Create date: 31/05/2024
-- Description:  This stored procedure is used to get Route for CabDriver
-- =============================================
CREATE PROCEDURE [dbo].[uspCabDriverRouteSelect](
@AcademicYearId SMALLINT,
@CabDriverId BIGINT
) AS Begin
SET
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET
  NOCOUNT ON;
BEGIN TRY 

DECLARE @SchoolCode NVARCHAR(15)


SELECT TOP 1 @SchoolCode = SchoolCode
FROM School 

SELECT
@SchoolCode AS SchoolCode,
v.CabDriverId,
r.VehicleId,
r.RouteId,
r.RouteName

FROM TransportRoute r 
INNER JOIN Vehicle v ON v.VehicleId = r.VehicleId
INNER JOIN CabDriver c ON c.CabDriverId = v.CabDriverId

WHERE
r.AcademicYearId=@AcademicYearId AND v.CabDriverId= @CabDriverId AND
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
GO


