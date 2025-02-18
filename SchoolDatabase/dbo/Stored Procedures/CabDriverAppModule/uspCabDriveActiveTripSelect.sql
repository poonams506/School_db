-- =============================================
-- Author:    Prathamesh Ghule
-- Create date: 14/08/2024
-- Description:  This stored procedure returns Active Trip for a specific user.
-- =============================================
CREATE PROCEDURE uspCabDriveActiveTripSelect (
  @UserId INT,
  @RouteId INT,
  @TripType NVARCHAR(10)
) 
AS 
BEGIN 
    -- Set the transaction isolation level to avoid locking issues
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    BEGIN TRY
       
            SELECT TOP (1)
                t.TripId,
                t.TripType,
                CASE 
                    WHEN t.TripEndTime IS NULL THEN 'Active Trip'
                    ELSE 'Completed Trip'
                END AS TripStatus
            FROM dbo.[Trip] t
            WHERE  
                t.IsDeleted <> 1
                AND t.CreatedBy = @UserId
                AND t.TripEndTime IS NULL
                AND CAST(t.TripStartTime AS DATE) = CAST(GETDATE() AS DATE) 
                AND (t.RouteId <> @RouteId OR (t.RouteId = @RouteId
                     AND t.TripType <> @TripType))
              ORDER BY t.TripId DESC; 
       
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
