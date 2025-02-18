﻿-- =============================================
-- Author:   Prathamesh Ghule
-- Create date: 19/02/2024
-- Description:  This stored procedure is used to get school event  data
-- =============================================
CREATE PROCEDURE uspSchoolEventDelete
	(
  @SchoolEventId INT = NULL,
  @UserId INT
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 

  DECLARE @CurrentDateTime DATETIME = GETDATE();
  BEGIN TRY
    -- Soft delete SchoolEvent
    UPDATE SchoolEvent 
    SET IsDeleted = 1,
     ModifiedBy=@UserId,
    ModifiedDate=@CurrentDateTime
    WHERE SchoolEventId = @SchoolEventId;

     -- Soft delete SchoolEventDetails
     UPDATE SchoolEventDetails 
    SET IsDeleted = 1,
     ModifiedBy=@UserId,
    ModifiedDate=@CurrentDateTime
    WHERE SchoolEventId = @SchoolEventId;
  
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

