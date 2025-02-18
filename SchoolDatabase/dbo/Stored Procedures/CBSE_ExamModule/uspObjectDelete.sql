-- =============================================
-- Author: Saurabh Walunj
-- Create date: 31/12/2024
-- Description: This stored procedure is used delete object name and out of marks in remove button
-- =============================================
CREATE PROCEDURE [dbo].[uspObjectDelete](
  @ExamObjectId BIGINT,
  @ExamMasterId BIGINT,
  @SubjectMasterId BIGINT,
  @AcademicYearId SMALLINT,
  @UserId INT
)
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    DECLARE @CurrentDateTime DATETIME = GETDATE();
    DECLARE @Status INT; 

    BEGIN TRY
        DELETE FROM dbo.CBSE_ExamResult
        WHERE ExamObjectId = @ExamObjectId
          AND ActualMarks IS NULL
          AND AcademicYearId = @AcademicYearId
          AND ExamObjectId NOT IN (
              SELECT ExamObjectId
              FROM dbo.CBSE_ExamResult AS er
              WHERE er.ExamObjectId = @ExamObjectId
                AND er.AcademicYearId = @AcademicYearId
                AND er.ActualMarks >= 0
          );

        IF EXISTS (
            SELECT 1
            FROM dbo.CBSE_ExamResult
            WHERE ExamObjectId = @ExamObjectId
              AND AcademicYearId = @AcademicYearId
        )
        BEGIN
            -- Record still exists
            SET @Status = 1;
        END
        ELSE
        BEGIN
            DELETE FROM dbo.CBSE_ExamObject
            WHERE ExamObjectId = @ExamObjectId
              AND SubjectMasterId = @SubjectMasterId
              AND ExamMasterId = @ExamMasterId
              AND AcademicYearId = @AcademicYearId;

            -- Record deleted successfully
            SET @Status = 0;
        END

        -- Return the status
        SELECT @Status AS OperationStatus;
     END TRY
  BEGIN CATCH 
    -- Error handling logic
    DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    DECLARE @ErrorNumber INT = ERROR_NUMBER();
    DECLARE @ErrorLine INT = ERROR_LINE();
    DECLARE @ErrorProcedure NVARCHAR(1000) = ERROR_PROCEDURE();
    EXEC uspExceptionLogInsert 
      @ErrorLine, 
      @ErrorMessage, 
      @ErrorNumber, 
      @ErrorProcedure, 
      @ErrorSeverity, 
      @ErrorState;
  END CATCH;
END;