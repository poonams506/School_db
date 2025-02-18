-- =============================================
-- Author:    Saurabh Walunj
-- Create date: 25/07/2024
-- Description:  This stored procedure is used delete Exam Object Data
-- =============================================
CREATE PROCEDURE [dbo].[uspExamObjectDelete](
  @ExamMasterId BIGINT,
  @SubjectMasterId BIGINT,
  @AcademicYearId SMALLINT,
  @UserId INT
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 
 
  DECLARE @CurrentDateTime DATETIME = GETDATE();
  	 DECLARE @ObjectCount INT;

	 
    SELECT @ObjectCount = COUNT(ExamMasterId)
	FROM CBSE_ExamResult as er
	inner join CBSE_ExamObject as eo on er.ExamObjectId = eo.ExamObjectId
	WHERE eo.ExamMasterId = @ExamMasterId 
	and eo.SubjectMasterId = @SubjectMasterId
	and eo.AcademicYearId = @AcademicYearId 
	and eo.IsDeleted <> 1
	AND er.IsDeleted <> 1;

	IF @ObjectCount = 0
BEGIN


  BEGIN TRY
    -- Soft delete ExamObject

    UPDATE CBSE_ExamObject
    
	SET IsDeleted = 1,
    ModifiedBy=@UserId,
    ModifiedDate=@CurrentDateTime
    
	WHERE 
	ExamMasterId = @ExamMasterId
	AND SubjectMasterId = @SubjectMasterId
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
else
SELECT 0 AS 'AffectedRows';
END