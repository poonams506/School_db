-- =============================================
-- Author: Chaitanya Kasar
-- Create date: 09/04/2024
-- Description: This stored procedure is used for  Vehicle Upsert
-- =============================================
CREATE PROCEDURE [dbo].[uspVehicleUpsert]
(
	@VehicleId BIGINT,
    @VehicleNumber NVARCHAR(10), 
	@TotalSeats INT,
    @RagistrationNumber NVARCHAR(20), 
	@ChassisNumber NVARCHAR(100), 
	@OwnerName NVARCHAR(100), 
	@FinancerName  NVARCHAR(100), 
	@EnginNumber NVARCHAR(100),
	@CompanyName  NVARCHAR(100), 
	@TankCapacity  NVARCHAR(100), 
	@Model NVARCHAR(100), 
	@Type NVARCHAR(100), 
	@FuelType NVARCHAR(100), 
	@CabDriverId BIGINT, 
	@Conductor NVARCHAR(100), 
	@DeviceId  NVARCHAR(100), 
	@ProviderName NVARCHAR(100), 
	@AcademicYearId SMALLINT,
	@VehicleDetailId BIGINT, 
	@VehicleRegistrationStartDate DATETIME,
	@VehicleRegistrationEndDate DATETIME,
	@VehiclePermitStartDate DATETIME,
	@VehiclePermitEndDate DATETIME,
	@VehicleInsuranceStartDate DATETIME,
	@VehicleInsuranceEndDate DATETIME,
	@VehiclePollutionStartDate DATETIME,
	@VehiclePollutionEndDate DATETIME,
	@VehicleRoadTaxStartDate DATETIME,
	@VehicleRoadTaxEndDate DATETIME,
	@VehicleFitnessStartDate DATETIME,
	@VehicleFitnessEndDate DATETIME,
	@Description NVARCHAR(500),
	@IsActive BIT = 0,
    @UserId INT
)
AS 
BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 

  DECLARE @CurrentDateTime DATETIME = GETDATE();
  BEGIN TRY
        IF EXISTS (SELECT TOP (1) 1 FROM dbo.Vehicle  
                   WHERE VehicleNumber = @VehicleNumber 
                   AND VehicleId <> @VehicleId
                   AND IsDeleted <> 1)
        BEGIN
            SELECT -1;
            RETURN;
        END
BEGIN TRANSACTION;
IF @VehicleId > 0 
BEGIN 
--Update Statement
UPDATE 
 Vehicle  
SET 
       [VehicleNumber]= @VehicleNumber,
       [TotalSeats]=@TotalSeats,
       [RagistrationNumber]=@RagistrationNumber,
       [ChassisNumber]=@ChassisNumber,
       [OwnerName]  =  @OwnerName,
       [FinancerName] = @FinancerName,
       [EnginNumber] = @EnginNumber, 
       [CompanyName]=@CompanyName,
       [TankCapacity]=@TankCapacity,
       [Model] = @Model,
       [Type] = @Type,
	   [FuelType] = @FuelType, 
       [CabDriverId]=@CabDriverId,
       [Conductor]=@Conductor,
       [DeviceId] = @DeviceId,
       [ProviderName] = @ProviderName,
	   [IsActive] = @IsActive,
       [ModifiedBy]=@UserId,
       [ModifiedDate]=@CurrentDateTime
   WHERE 
  [VehicleId] = @VehicleId

   DELETE FROM dbo.VehicleDetail 
            WHERE VehicleId = @VehicleId;

			    -- insert for VehicleDetail
            INSERT INTO dbo.VehicleDetail(VehicleId, VehicleRegistrationStartDate, VehicleRegistrationEndDate, 
			VehiclePermitStartDate, VehiclePermitEndDate, VehicleInsuranceStartDate, VehicleInsuranceEndDate,
			VehiclePollutionStartDate, VehiclePollutionEndDate, VehicleRoadTaxStartDate, VehicleRoadTaxEndDate, 
			VehicleFitnessStartDate, VehicleFitnessEndDate,Description, AcademicYearId, CreatedBy, CreatedDate)

             VALUES( @VehicleId, @VehicleRegistrationStartDate, @VehicleRegistrationEndDate,
			@VehiclePermitStartDate, @VehiclePermitEndDate, @VehicleInsuranceStartDate,
			@VehicleInsuranceEndDate, @VehiclePollutionStartDate, @VehiclePollutionEndDate,
			@VehicleRoadTaxStartDate, @VehicleRoadTaxEndDate, @VehicleFitnessStartDate, 
			@VehicleFitnessEndDate, @Description, @AcademicYearId, @UserId, @CurrentDateTime
            )

			 END 
			
  ELSE 
  BEGIN --INSERT Statement
  INSERT INTO Vehicle(
       [AcademicYearId],
       [VehicleNumber],
       [TotalSeats],
       [RagistrationNumber],
       [ChassisNumber],
       [OwnerName],
       [FinancerName],
       [EnginNumber], 
       [CompanyName],
       [TankCapacity],
       [Model],
       [Type],
	   [FuelType], 
       [CabDriverId],
       [Conductor],
       [DeviceId],
       [ProviderName],
	   [IsActive],
       [CreatedBy],
       [CreatedDate]
       ) 
    VALUES 
 (
  @AcademicYearId,
  @VehicleNumber,
  @TotalSeats,
  @RagistrationNumber,
  @ChassisNumber,
  @OwnerName,
  @FinancerName,
  @EnginNumber, 
  @CompanyName,
  @TankCapacity,
  @Model,
  @Type,
  @FuelType, 
  @CabDriverId,
  @Conductor,
  @DeviceId,
  @ProviderName,
  @IsActive,
  @UserId,
  @CurrentDateTime
 )
   SET @VehicleId = SCOPE_IDENTITY();

            -- insert for VehicleDetail
     INSERT INTO dbo.VehicleDetail(VehicleId, VehicleRegistrationStartDate, VehicleRegistrationEndDate, 
			VehiclePermitStartDate, VehiclePermitEndDate, VehicleInsuranceStartDate, VehicleInsuranceEndDate,
			VehiclePollutionStartDate, VehiclePollutionEndDate, VehicleRoadTaxStartDate, VehicleRoadTaxEndDate, 
			VehicleFitnessStartDate, VehicleFitnessEndDate,Description, AcademicYearId, CreatedBy, CreatedDate)

            VALUES( @VehicleId, @VehicleRegistrationStartDate, @VehicleRegistrationEndDate,
			@VehiclePermitStartDate, @VehiclePermitEndDate, @VehicleInsuranceStartDate,
			@VehicleInsuranceEndDate, @VehiclePollutionStartDate, @VehiclePollutionEndDate,
			@VehicleRoadTaxStartDate, @VehicleRoadTaxEndDate, @VehicleFitnessStartDate, 
			@VehicleFitnessEndDate, @Description, @AcademicYearId, @UserId, @CurrentDateTime
            )
     END 
	
 COMMIT;
 END TRY 
 BEGIN CATCH
 ROLLBACK;
 DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
 DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
 DECLARE @ErrorState INT = ERROR_STATE();
 DECLARE @ErrorNumber INT = ERROR_NUMBER();
 DECLARE @ErrorLine INT = ERROR_PROCEDURE();
 DECLARE @ErrorProcedure NVARCHAR(1000) = ERROR_LINE();
 EXEC uspExceptionLogInsert @ErrorLine, 
 @ErrorMessage, 
 @ErrorNumber, 
 @ErrorProcedure, 
 @ErrorSeverity, 
 @ErrorState;
 THROW;
 END CATCH END