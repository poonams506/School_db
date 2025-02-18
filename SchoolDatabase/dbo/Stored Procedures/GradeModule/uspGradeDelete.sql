-- =============================================
-- Author:    Meena Kotkar
-- Create date: 22/11/2023
-- Description:  This stored procedure is used delete Grade data
-- =============================================
CREATE PROCEDURE [dbo].[uspGradeDelete] (
  @GradeId INT = NULL,
  @AcademicYearId INT,
  @UserId INT
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 

  DECLARE @CurrentDateTime DATETIME = GETDATE();
    DECLARE @return_value int
	EXEC @return_value = uspGradeExits @GradeId, @AcademicYearId;
	--Select 'return value'=@return_value;
	IF @return_value = 0
  BEGIN
    BEGIN TRY
      UPDATE Grade 
		SET IsDeleted=1,
        ModifiedBy=@UserId,
        ModifiedDate=@CurrentDateTime
		WHERE GradeId=@GradeId;
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