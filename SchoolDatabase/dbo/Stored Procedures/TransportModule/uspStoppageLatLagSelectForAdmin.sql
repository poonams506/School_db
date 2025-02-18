-- =============================================
-- Author:    Shambala Apugade
-- Create date: 07/08/2024
-- Description:  This stored procedure returns Stoppage Lat Lng for Admin.
-- =============================================


CREATE PROCEDURE [dbo].[uspStoppageLatLagSelectForAdmin]
	@AcademicYearId INT,
	@RouteId INT
	AS Begin
SET
TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET
  NOCOUNT ON;
   DECLARE @CurrentDate DATE = CAST(GETDATE() AS DATE);
BEGIN TRY  

SELECT 
 S.OrderNo,
 S.StoppageName AS StopName,
 S.StopLat AS Lat,
 S.StopLng AS Lng
FROM dbo.TransportStoppage S
INNER JOIN dbo.TransportArea A ON S.AreaId=A.AreaId
WHERE
S.AcademicYearId=@AcademicYearId AND S.RouteId = @RouteId AND S.IsDeleted<>1 
  
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
