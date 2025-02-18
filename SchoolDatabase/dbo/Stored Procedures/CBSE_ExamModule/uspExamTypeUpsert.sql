-- =============================================
-- Author: Saurabh Walunj 
-- Create date: 25/07/2024
-- Description: This stored procedure is used for Exam type Upsert 
-- =============================================
CREATE PROCEDURE [dbo].[uspExamTypeUpsert](
  @ExamTypeId SMALLINT,
  @ExamTypeName NVARCHAR(200),
  @UserId INT
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON DECLARE @CurrentDateTime DATETIME = GETDATE();
BEGIN TRY IF @ExamTypeId > 0 BEGIN --Update Statement
UPDATE 
  CBSE_ExamType
SET 
  [ExamTypeName] = @ExamTypeName, 
  [ModifiedBy] = @UserId, 
  [ModifiedDate] = @CurrentDateTime
WHERE 
   [ExamTypeId] =  @ExamTypeId END ELSE BEGIN --INSERT Statement
  INSERT INTO CBSE_ExamType(
  [ExamTypeId] ,
  [ExamTypeName],    
  [CreatedBy],
  [CreatedDate]
  ) 
VALUES 
  (
  @ExamTypeId, 
  @ExamTypeName,  
  @UserId, 
  @CurrentDateTime
  ) 
  SET @ExamTypeId = SCOPE_IDENTITY();
  END 
END TRY BEGIN CATCH DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
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