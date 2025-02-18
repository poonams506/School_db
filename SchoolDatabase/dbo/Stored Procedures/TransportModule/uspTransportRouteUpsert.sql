-- =============================================
-- Author:    Meena Kotkar
-- Create date: 09/04/2024
-- Description:  This stored procedure is used insert transport route details 
-- =============================================
CREATE PROCEDURE [dbo].[uspTransportRouteUpsert](
  @RouteId BIGINT,
  @IsSharedVehicle BIT,
  @RouteName NVARCHAR(100),
  @FirstPickUpTime DATETIME,
  @LastPickUpTime DATETIME,
  @VehicleId BIGINT,
  @CoOrdinatorId NVARCHAR(50),
  @CoOrdinatorRoleId INT,
  @AcademicYearId SMALLINT, 
  @UserId INT
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON DECLARE @CurrentDateTime DATETIME = GETDATE();
  DECLARE @VehicleRegistrationNo NVARCHAR(50);
  select @VehicleRegistrationNo=RagistrationNumber From Vehicle where VehicleId=@VehicleId;
BEGIN TRY IF @RouteId > 0 BEGIN --Update Statement
UPDATE 
  TransportRoute 
SET 
  [RouteName] = @RouteName, 
  [FirstPickUpTime] = @FirstPickUpTime, 
  [LastPickUpTime] = @LastPickUpTime, 
  [VehicleId] = @VehicleId, 
  [SharedRouteId]=CASE WHEN @IsSharedVehicle=1 THEN @VehicleRegistrationNo ELSE NULL END,
  [IsSharedVehicle]=@IsSharedVehicle,
  [CoOrdinatorId] = @CoOrdinatorId,
  [CoOrdinatorRoleId] = @CoOrdinatorRoleId, 
  [AcademicYearId] = @AcademicYearId, 
  [ModifiedBy] = @UserId, 
  [ModifiedDate] = @CurrentDateTime
WHERE 
   [RouteId] =  @RouteId END ELSE BEGIN --INSERT Statement
  INSERT INTO TransportRoute(
        [RouteName] , 
        [FirstPickUpTime] , 
        [LastPickUpTime] , 
        [VehicleId] , 
        [CoOrdinatorId] ,
        [CoOrdinatorRoleId] ,
        [AcademicYearId] , 
        [SharedRouteId],
        [IsSharedVehicle],
        [CreatedBy],
        [CreatedDate]
      ) 
VALUES 
  (
       @RouteName, 
       @FirstPickUpTime, 
       @LastPickUpTime, 
       @VehicleId, 
       @CoOrdinatorId,  
       @CoOrdinatorRoleId,
       @AcademicYearId, 
        CASE WHEN @IsSharedVehicle=1 THEN @VehicleRegistrationNo ELSE NULL END,
       @IsSharedVehicle,
       @UserId, 
       @CurrentDateTime
      
  )
  SET @RouteId = SCOPE_IDENTITY();
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
@ErrorState END CATCH END