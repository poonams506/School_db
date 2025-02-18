-- =============================================
-- Author:    Poonam Bhalke
-- Create date: 20/02/2024
-- Description:  This stored procedure is used to delet  data
-- =============================================

CREATE PROCEDURE uspSchoolHolidayDelete
	(
 @SchoolHolidayId INT = NULL,
 @UserId INT
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 

  DECLARE @CurrentDateTime DATETIME = GETDATE();
  BEGIN TRY
    -- Soft delete SchoolEvent
    UPDATE SchoolHolidays 
    SET IsDeleted = 1,
    ModifiedBy=@UserId,
    ModifiedDate=@CurrentDateTime
    WHERE SchoolHolidayId = @SchoolHolidayId;

  END TRY
  BEGIN CATCH
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
