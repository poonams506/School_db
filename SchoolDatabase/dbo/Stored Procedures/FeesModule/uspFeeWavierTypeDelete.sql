-- =============================================
-- Author:    Meena Kotkar
-- Create date: 5/12/2023
-- Description:  This stored procedure is used delete Fee Wavier type Data
-- =============================================
CREATE PROCEDURE [dbo].[uspFeeWavierTypeDelete]
(
     @FeeWavierTypeId INT = NULL,
      @UserId INT
)
 AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 

 DECLARE @CurrentDateTime DATETIME = GETDATE();
  DECLARE @TypeCount INT;

    SELECT @TypeCount = COUNT(@FeeWavierTypeId)
	FROM FeeParticularWavierMapping
	 WHERE FeeWavierTypeId = @FeeWavierTypeId;
	
	IF @TypeCount = 0

	  BEGIN TRY
		UPDATE FeeWavierTypes 
		SET IsDeleted=1,
        ModifiedBy=@UserId,
        ModifiedDate=@CurrentDateTime
		WHERE FeeWavierTypeId=@FeeWavierTypeId;

        UPDATE FeeWavierTypesInstallmentsDetails 
		SET IsDeleted=1,
        ModifiedBy=@UserId,
        ModifiedDate=@CurrentDateTime
		WHERE FeeWavierTypeId=@FeeWavierTypeId;

		 SELECT 1 AS 'AffectedRows';
              
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
	ELSE
  BEGIN
    -- Return 0 if the Grade does not exist
    SELECT 0 AS 'AffectedRows';
  END
  END
  