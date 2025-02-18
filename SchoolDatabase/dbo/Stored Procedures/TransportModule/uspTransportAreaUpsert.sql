-- =============================================
-- Author:    Meena Kotkar
-- Create date: 09/04/2024
-- Description:  This stored procedure is used insert tranport area details 
-- =============================================
CREATE PROCEDURE [dbo].[uspTransportAreaUpsert](
  @AreaId BIGINT,
  @AreaName NVARCHAR(100),
  @PickPrice MONEY,
  @DropPrice MONEY,
  @PickAndDropPrice MONEY,
  @Description NVARCHAR(500),
  @AcademicYearId SMALLINT, 
  @UserId INT
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON DECLARE @CurrentDateTime DATETIME = GETDATE();
BEGIN TRY IF @AreaId > 0 BEGIN --Update Statement
UPDATE 
  TransportArea 
SET 
  [AreaName] = @AreaName, 
  [PickPrice] = @PickPrice, 
  [DropPrice] = @DropPrice, 
  [PickAndDropPrice] = @PickAndDropPrice, 
  [Description] = @Description, 
  [AcademicYearId] = @AcademicYearId, 
  [ModifiedBy] = @UserId, 
  [ModifiedDate] = @CurrentDateTime
WHERE 
   [AreaId] =  @AreaId END ELSE BEGIN --INSERT Statement
  INSERT INTO TransportArea( 
  [AreaName], 
  [PickPrice] , 
  [DropPrice], 
  [PickAndDropPrice], 
  [Description] , 
  [AcademicYearId] ,  
    [CreatedBy],
    [CreatedDate]
  ) 
VALUES 
  (
  @AreaName, 
  @PickPrice, 
  @DropPrice, 
   @PickAndDropPrice, 
   @Description, 
   @AcademicYearId, 
 @UserId, 
  @CurrentDateTime
  ) 
  SET @AreaId = SCOPE_IDENTITY();
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
