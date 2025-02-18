--===============================================
-- Author:    Prerana Aher
-- Create date: 25/7/2024
-- Description:  This stored procedure is used for Exam Master Upsert 
-- =============================================
CREATE PROCEDURE [dbo].[uspExamMasterUpsert]
(   @ExamMasterId SMALLINT,
	@AcademicYearId SMALLINT,
	@ExamName NVARCHAR(200),
	@ExamTypeId SMALLINT,
	@TermId SMALLINT,
	@UserId INT
)	
AS 
BEGIN 
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;
    DECLARE @CurrentDateTime DATETIME = GETDATE();
	 
    BEGIN TRY  IF EXISTS (SELECT TOP (1) ExamMasterId  FROM dbo.CBSE_ExamMaster
			WHERE ExamMasterId<>@ExamMasterId AND 
			ExamName=@ExamName 
			AND TermId=@TermId
			AND ExamTypeId=@ExamTypeId
			AND AcademicYearId=@AcademicYearId AND
			IsDeleted=0 ORDER BY ExamName)
	BEGIN
		SELECT -1;
	END
	ELSE
	
        IF @ExamMasterId > 0 
        BEGIN

            UPDATE dbo.CBSE_ExamMaster
            SET 
				[AcademicYearId] = @AcademicYearId,
                [ExamName] = @ExamName,
				[ExamTypeId] = @ExamTypeId,
				[TermId] = @TermId,
				[ModifiedBy] = @UserId,
				[ModifiedDate] = @CurrentDateTime
				
 WHERE 
  [ExamMasterId] = @ExamMasterId;
     
  
  END ELSE BEGIN 
 
INSERT INTO CBSE_ExamMaster(
    [AcademicYearId],
	[ExamName],
	[ExamTypeId],
	[TermId],
	[CreatedBy],
	[CreatedDate]
	) 
  VALUES 
  (
   @AcademicYearId,
   @ExamName,
   @ExamTypeId,
   @TermId,
   @UserId,
   @CurrentDateTime
  ) 

  SET @ExamMasterId = SCOPE_IDENTITY();

 
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