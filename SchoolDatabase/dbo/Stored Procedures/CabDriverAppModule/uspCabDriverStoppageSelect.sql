-- =============================================
-- Author: Saurabh Walunj
-- Create date: 10/06/2024
-- Description: This stored procedure is used to cab driver stoppage info
-- =============================================
CREATE PROCEDURE [dbo].[uspCabDriverStoppageSelect](
@AcademicYearId SMALLINT,
@RouteId BIGINT,
@TripType NVARCHAR(10)
) AS Begin
SET
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET
  NOCOUNT ON;
BEGIN TRY 

IF @TripType = 'PickUp'
BEGIN
Select 
s.StoppageId,
s.StoppageName,
s.RouteId,
s.OrderNo

From TransportStoppage s
inner join TransportRoute r on r.RouteId = s.RouteId

Where
s.RouteId = @RouteId
And s.AcademicYearId = @AcademicYearId
AND s.IsDeleted <> 1

Order by OrderNo
END

ELSE

BEGIN
SELECT 
s.StoppageId,
s.StoppageName,
s.RouteId,
s.OrderNo

FROM TransportStoppage s
INNER JOIN TransportRoute r ON r.RouteId= s.RouteId

WHERE s.RouteId = @RouteId
AND s.AcademicYearId = @AcademicYearId
AND s.IsDeleted <> 1

ORDER BY OrderNo DESC
END

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
@ErrorState END CATCH End



