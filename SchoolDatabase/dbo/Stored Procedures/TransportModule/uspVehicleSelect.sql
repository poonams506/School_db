-- =============================================
-- Author:   Chaitanya Kasar
-- Create date: 09/04/2024
-- Description:  This stored procedure is used to get Vehicle data
-- =============================================
CREATE PROCEDURE uspVehicleSelect (@VehicleId BIGINT, @AcademicYearId INT)AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 


 SELECT 
        v.VehicleId,
        v.AcademicYearId,
        v.VehicleNumber,
        v.TotalSeats,
        v.RagistrationNumber,
        v.ChassisNumber,
        v.OwnerName,
        v.FinancerName,
        v.EnginNumber,
        v.CompanyName,
        v.TankCapacity,
        v.Model,
        v.Type,
        v.FuelType,
        v.CabDriverId,
        v.Conductor,
        v.DeviceId,
        v.ProviderName,
        v.IsActive,
        vd.VehicleDetailId,
        vd.VehicleRegistrationStartDate,
        vd.VehicleRegistrationEndDate,
        vd.VehiclePermitStartDate,
        vd.VehiclePermitEndDate,
        vd.VehicleInsuranceStartDate,
        vd.VehicleInsuranceEndDate,
        vd.VehiclePollutionStartDate,
        vd.VehiclePollutionEndDate,
        vd.VehicleRoadTaxStartDate,
        vd.VehicleRoadTaxEndDate,
        vd.VehicleFitnessStartDate,
        vd.VehicleFitnessEndDate,
        vd.Description
       
    FROM 
        Vehicle v
    INNER JOIN 
        VehicleDetail vd ON v.VehicleId = vd.VehicleId
    WHERE 
              v.VehicleId = @VehicleId
			  AND vd.AcademicYearId=@AcademicYearId
              AND vd.IsDeleted <> 1
              AND V.IsDeleted <> 1

  
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




