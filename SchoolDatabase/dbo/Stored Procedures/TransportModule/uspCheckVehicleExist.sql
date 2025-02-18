-- =============================================
-- Author:   Chaitanya Kasar
-- Create date: 15/05/2024
-- Description:  This stored procedure is used to check Vehicle  exist or not 
-- =============================================

CREATE PROCEDURE [dbo].[uspCheckVehicleExist]
(
    @VehicleId INT= NULL
)
    AS 
    BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    BEGIN TRY 
    DECLARE @CurrentDateTime DATETIME = GETDATE();
    DECLARE @VehicleCount INT;
    SELECT @VehicleCount = COUNT(VehicleId) 
    FROM TransportRoute
    WHERE VehicleId = @VehicleId AND IsDeleted<>1;

     SELECT @VehicleCount as 'VehicleCount';
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

