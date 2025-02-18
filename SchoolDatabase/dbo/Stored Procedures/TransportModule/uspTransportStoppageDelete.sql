-- =============================================
-- Author:    Meena Kotkar
-- Create date: 10/04/2024
-- Description:  This stored procedure is used delete stoppage data
-- =============================================
CREATE PROCEDURE [dbo].[uspTransportStoppageDelete] (
  @StoppageId INT = NULL,
  @AcademicYearId SMALLINT,
  @UserId INT
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 

  DECLARE @CurrentDateTime DATETIME = GETDATE();
   DECLARE @stoppageCount INT;

    SELECT @stoppageCount = COUNT(StoppageId)
	FROM TransportConsumerStoppageMapping 
    WHERE StoppageId = @StoppageId and AcademicYearId = @AcademicYearId AND IsDeleted<>1;
	
	IF @stoppageCount = 0
  BEGIN
    BEGIN TRY
      UPDATE TransportStoppage 
		SET IsDeleted=1,
        ModifiedBy=@UserId,
        ModifiedDate=@CurrentDateTime
      WHERE StoppageId = @StoppageId AND AcademicYearId=@AcademicYearId;
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
  END
   ELSE
  BEGIN
    -- Return 0 if the Grade does not exist
    SELECT 0 AS 'AffectedRows';
  END
END