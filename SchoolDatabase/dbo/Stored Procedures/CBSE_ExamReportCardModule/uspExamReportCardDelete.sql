-- =============================================
-- Author: Saurabh Walunj 
-- Create date: 29/08/2024
-- Description:  This stored procedure is used to get Exam Report Card info in Grid
-- =============================================
CREATE PROCEDURE [dbo].[uspExamReportCardDelete]
	(
  @ExamReportCardNameId INT = NULL,
  @UserId INT = NULL
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 

  DECLARE @CurrentDateTime DATETIME = GETDATE();
  BEGIN TRY
    -- Soft delete CBSE_ExamReportCardName
    UPDATE CBSE_ExamReportCardName 
    SET IsDeleted = 1,
     ModifiedBy=@UserId,
    ModifiedDate=@CurrentDateTime
    WHERE ExamReportCardNameId = @ExamReportCardNameId;

     -- Soft delete CBSE_ReportCardClasses
     UPDATE CBSE_ReportCardClasses 
    SET IsDeleted = 1,
     ModifiedBy=@UserId,
    ModifiedDate=@CurrentDateTime
    WHERE ExamReportCardNameId = @ExamReportCardNameId;

	   -- Soft delete CBSE_ReportCardExam
     UPDATE CBSE_ReportCardExam 
    SET IsDeleted = 1,
     ModifiedBy=@UserId,
    ModifiedDate=@CurrentDateTime
    WHERE ExamReportCardNameId = @ExamReportCardNameId;
  
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