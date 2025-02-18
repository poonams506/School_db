-- ==================================
-- Author:   prathamesh Ghule
-- Create date: 26/08/2024
-- Description: This stored procedure is used to post examResult info in CBSE_examResult Table
-- =============================================
CREATE PROCEDURE [dbo].[uspExamResultUpsert]
	@AcademicYearId SMALLINT,
    @UserId INT,
	@ExamResultType [dbo].[CBSE_ExamResultType] READONLY
 AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 
 DECLARE @CurrentDateTime DATETIME = GETDATE();

BEGIN TRY
   IF (SELECT COUNT(*) FROM @ExamResultType) > 0
BEGIN
    DELETE CBSE_ExamResult  
    FROM CBSE_ExamResult cer
    INNER JOIN @ExamResultType et
    ON cer.ExamObjectId = et.ExamObjectId AND cer.StudentId = et.StudentId AND cer.AcademicYearId=@AcademicYearId;
END

    INSERT INTO CBSE_ExamResult(
   [AcademicYearId],[StudentId],[ExamObjectId],[OutOfMarks],[ActualMarks],
   [TotalMarks],[Percentage],[Grade],[CreatedBy],[CreatedDate]
   )
   SELECT @AcademicYearId,ert.StudentId,ert.ExamObjectId,ert.OutOfMarks, ert.ActualMarks,ert.TotalMarks,
         ert.Percentage,ert.Grade,@UserId,@CurrentDateTime
   FROM @ExamResultType As ert
    WHERE NOT EXISTS (
     SELECT 1 
     FROM CBSE_ExamResult er
     WHERE er.StudentId=ert.StudentId AND er.ExamObjectId=ert.ExamObjectId AND er.AcademicYearId=@AcademicYearId
 );
END TRY 
BEGIN CATCH DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
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
@ErrorState END CATCH END