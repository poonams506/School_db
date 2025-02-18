-- =============================================
-- Author:    Meena Kotkar
-- Create date: 10/04/2024
-- Description:  This stored procedure is used to get Stoppage info
-- =============================================
CREATE PROCEDURE [dbo].[uspTransportStoppageSelect](
    @StoppageId INT,
    @AcademicYearId SMALLINT) AS Begin
SET
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET
  NOCOUNT ON;
BEGIN TRY                  
 SELECT 
 S.StoppageId,
 S.OrderNo,
  S.StoppageName,
  A.AreaName,
  A.AreaId,
  S.PickPrice,
  S.DropPrice,
  S.PickAndDropPrice,
  S.PickUpTime,
  S.DropPickUpTime,
  S.KiloMeter,
  S.StopLat,
  S.StopLng

  FROM TransportStoppage S
   INNER JOIN TransportArea A ON S.AreaId=A.AreaId
  WHERE 
  S.StoppageId=@StoppageId AND 
  S.AcademicYearId=@AcademicYearId
  AND A.AcademicYearId = @AcademicYearId
  AND S.IsDeleted <> 1
  AND ISNULL(A.IsDeleted,0)<>1 
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