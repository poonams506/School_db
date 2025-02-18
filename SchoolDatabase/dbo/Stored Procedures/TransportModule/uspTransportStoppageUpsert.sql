-- =============================================
-- Author:    Meena Kotkar
-- Create date: 10/04/2024
-- Description:  This stored procedure is used upsert transport stoppage details 
-- =============================================
CREATE PROCEDURE [dbo].[uspTransportStoppageUpsert](
  @StoppageId BIGINT,
  @StoppageName NVARCHAR(100),
  @OrderNo INT,
  @AreaId BIGINT,
  @PickPrice MONEY,
  @DropPrice MONEY,
  @PickAndDropPrice MONEY,
  @PickUpTime DATETIME,
  @DropPickUpTime DATETIME,
  @KiloMeter NVARCHAR(50),
  @AcademicYearId SMALLINT,
  @RouteId BIGINT,
  @StopLat NVARCHAR(200),
  @StopLng NVARCHAR(200),
  @UserId INT
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON DECLARE @CurrentDateTime DATETIME = GETDATE();
  IF EXISTS (SELECT TOP (1) 1 FROM dbo.TransportStoppage  
                   WHERE OrderNo = @OrderNo AND RouteId=@RouteId
                   AND StoppageId <> @StoppageId
                   AND AcademicYearId=@AcademicYearId
                   AND IsDeleted <>1)
        BEGIN
            SELECT -1;
	   RETURN;
        END
BEGIN TRY IF @StoppageId > 0 BEGIN --Update Statement
UPDATE 
  TransportStoppage
SET 
  [StoppageName] = @StoppageName, 
  [OrderNo] = @OrderNo, 
  [AreaId] = @AreaId, 
  [PickPrice] = @PickPrice, 
  [DropPrice] = @DropPrice, 
  [PickAndDropPrice] = @PickAndDropPrice, 
  [PickUpTime] = @PickUpTime,
  [DropPickUpTime] = @DropPickUpTime,
  [KiloMeter]=@KiloMeter,
  [AcademicYearId] = @AcademicYearId, 
  [RouteId]=@RouteId,
  [StopLat]=@StopLat,
  [StopLng]=@StopLng,
  [ModifiedBy] = @UserId, 
  [ModifiedDate] = @CurrentDateTime
WHERE 
   [StoppageId] =  @StoppageId END ELSE BEGIN --INSERT Statement
  INSERT INTO TransportStoppage(
        [StoppageName], 
        [OrderNo], 
        [AreaId], 
        [PickPrice], 
        [DropPrice], 
        [PickAndDropPrice], 
        [PickUpTime],
        [DropPickUpTime],
		[KiloMeter],
        [AcademicYearId] ,
        [RouteId],
        [StopLat],
        [StopLng],
        [CreatedBy],
        [CreatedDate]
  ) 
VALUES 
  (
        @StoppageName, 
        @OrderNo, 
        @AreaId, 
        @PickPrice, 
        @DropPrice, 
        @PickAndDropPrice, 
        @PickUpTime,
       @DropPickUpTime,
	   @KiloMeter,
       @AcademicYearId, 
       @RouteId,
       @StopLat,
       @StopLng,
       @UserId, 
       @CurrentDateTime
  ) 
  SET @StoppageId = SCOPE_IDENTITY();
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