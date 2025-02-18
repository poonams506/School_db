-- =============================================
-- Author:    Meena Kotkar
-- Create date: 09/08/2024
-- Description:  This stored procedure is used to  Stoppage lat and lag by student info
-- =============================================
CREATE  PROCEDURE [dbo].[uspStoppageLatLagSelect](
    @StudentId INT,
    @AcademicYearId SMALLINT) AS Begin
SET
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET
  NOCOUNT ON;
BEGIN TRY    
Declare @StoppageId BIGINT;
Declare @RouteId BIGINT;

			 SELECT TOP 1  @StoppageId= S.StoppageId,
			 @RouteId=s.RouteId
			  FROM TransportStoppage S
			  INNER JOIN TransportConsumerStoppageMapping cs ON S.StoppageId= cs.StoppageId AND cs.RoleId=5
			  WHERE 
			  cs.ConsumerId=@StudentId AND 
			  S.AcademicYearId=@AcademicYearId
			  AND S.IsDeleted <> 1
			  AND CAST(cs.FromDate AS DATE) <= CAST(GETDATE() AS DATE) AND CAST(cs.ToDate AS DATE) >= CAST(GETDATE() AS DATE)

SELECT 
 S.OrderNo,
  S.StoppageName AS StopName,
  S.StopLat AS Lat,
  S. StopLng AS Lng
  

  FROM dbo.TransportStoppage S
   INNER JOIN dbo.TransportArea A ON S.AreaId=A.AreaId
  WHERE
  S.AcademicYearId=@AcademicYearId AND 
  S.RouteId=@RouteId AND S.IsDeleted<>1 
  
  UNION ALL 
   SELECT 
  9999 As OrderNo,
  'School' AS StopName,
  s.SchoolLat AS Lat,
  s.SchoolLng AS Lng
  FROM dbo.School s
  WHERE
  s.AcademicYearId=@AcademicYearId  

  ORDER BY OrderNo

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