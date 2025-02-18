CREATE PROCEDURE uspCabDriverTripCurrentLocationAppSelect
    @AcademicYearId INT,  
    @StudentId INT
AS 
BEGIN 
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    DECLARE @CurrentDate DATE = CAST(GETDATE() AS DATE);

    BEGIN TRY 
       DECLARE @RouteId INT ;
       SET @RouteId = (SELECT  top 1  t.RouteId
        FROM dbo.TransportConsumerStoppageMapping m 
        INNER JOIN dbo.TransportStoppage t ON t.StoppageId = m.StoppageId
        INNER JOIN dbo.Student s ON m.ConsumerId = s.StudentId AND m.RoleId = 5 
        INNER JOIN dbo.StudentGradeDivisionMapping sgdm ON s.StudentId=sgdm.StudentId 
						        AND sgdm.AcademicYearId=@AcademicYearId
                                AND CAST(m.FromDate AS DATE) <= CAST(GETDATE() AS DATE) AND CAST(m.ToDate AS DATE) >= CAST(GETDATE() AS DATE)

        WHERE  m.ConsumerId = @StudentId AND m.AcademicYearId = @AcademicYearId 
              AND m.IsDeleted <>1 AND t.IsDeleted <> 1 AND s.StudentId = @StudentId 
              AND sgdm.IsDeleted <> 1 AND m.RoleId = 5 ORDER BY t.RouteId DESC)
       
       IF @RouteId > 0
       BEGIN
            SELECT top 1 cl.Lat, cl.Long Lng, v.VehicleNumber VehicleNo, v.RagistrationNumber RegistrationNo, concat(d.FirstName ,' ', d.LastName) FROM Trip t 
            INNER JOIN CabDriverTripCurrentLocation cl
            ON cl.TripId = t.TripId
            INNER JOIN TransportRoute r 
            ON r.RouteId = r.RouteId
            INNER JOIN Vehicle v
            ON r.VehicleId = v.VehicleId
            INNER JOIN CabDriver d
            ON v.CabDriverId = d.CabDriverId
            WHERE t.RouteId = @RouteId AND CAST(t.CreatedDate AS DATE) = @CurrentDate AND t.IsDeleted <> 1
            AND CAST(cl.LastSyncDate AS DATE) = @CurrentDate AND t.TripEndTime IS NULL
            ORDER BY cl.LastSyncDate desc
       END


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
    END CATCH 
END;

