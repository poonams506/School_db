-- =============================================
-- Author:   Chaitanya Kasar
-- Create date: 09/04/2024
-- Description:  This stored procedure is used to Delete Vehicle  data
-- =============================================
CREATE PROCEDURE uspVehicleDelete
	(
  @VehicleId INT = NULL,
  @UserId INT
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 

  DECLARE @CurrentDateTime DATETIME = GETDATE();
  BEGIN TRY
    -- Soft delete Vehicle
    UPDATE Vehicle 
    SET IsDeleted = 1,
    ModifiedBy=@UserId,
    ModifiedDate=@CurrentDateTime
    WHERE VehicleId = @VehicleId;
     SELECT 1 as 'AffectedRows';

     -- Soft delete VehicleDetail
     UPDATE VehicleDetail 
    SET IsDeleted = 1,
    ModifiedBy=@UserId,
    ModifiedDate=@CurrentDateTime
    WHERE VehicleId = @VehicleId;
  
  END TRY
  BEGIN CATCH
    -- Log the exception
    DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
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
                               @ErrorState;
  END CATCH
END

