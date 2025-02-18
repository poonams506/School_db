-- =============================================
-- Author:    Meena Kotkar
-- Create date: 5/12/2023
-- Description:  This stored procedure is used delete Admin Data
-- =============================================
CREATE PROCEDURE [dbo].[uspAdminDelete]
(
     @AdminId INT = NULL,
      @UserId INT
)
 AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 

 DECLARE @CurrentDateTime DATETIME = GETDATE();
	  BEGIN TRY
		UPDATE Admin 
		SET IsDeleted=1,
         ModifiedBy=@UserId,
         ModifiedDate=@CurrentDateTime
		WHERE AdminId=@AdminId;
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
  