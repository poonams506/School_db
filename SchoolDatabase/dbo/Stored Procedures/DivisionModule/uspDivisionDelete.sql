-- =============================================
-- Author:    Meena Kotkar
-- Create date: 28/11/2023
-- Description:  This stored procedure is used delete Division data
-- =============================================
CREATE PROCEDURE [dbo].[uspDivisionDelete] (
  @DivisionId INT = NULL,
  @AcademicYearId SMALLINT,
   @UserId INT
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 

  DECLARE @CurrentDateTime DATETIME = GETDATE();
	 DECLARE @StudentCount INT;

    SELECT @StudentCount = COUNT(DivisionId)
	FROM SchoolGradeDivisionMatrix
	 WHERE DivisionId = @DivisionId and AcademicYearId = @AcademicYearId and IsDeleted <> 1;
	
	IF @StudentCount<1
	BEGIN
		SELECT @StudentCount =  @StudentCount +COUNT(DivisionId)
		FROM StudentGradeDivisionMapping
		WHERE DivisionId = @DivisionId AND AcademicYearId = @AcademicYearId and IsDeleted <>1;
        SELECT 1 AS 'AffectedRows';
	END
	IF @StudentCount = 0
  BEGIN
    BEGIN TRY
      UPDATE Division 
		SET IsDeleted=1,
         ModifiedBy=@UserId,
         ModifiedDate=@CurrentDateTime
      WHERE DivisionId = @DivisionId;
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