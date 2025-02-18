-- =============================================
-- Author:    Abhishek Kumar
-- Create date: 16/09/2023
-- Description:  This stored procedure is used publish/Unpublish FeeParticular data
-- =============================================
CREATE PROCEDURE [dbo].[uspStudentKitFeeParticularIsPublishUpdate]
(
	@AcademicYearId INT,
	@GradeId INT,
	@DivisionId INT,
	@IsPublish BIT,
	@UserId INT
)

AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 
	
DECLARE @CurrentDateTime DATETIME = GETDATE();
BEGIN TRY 

    UPDATE dbo.StudentKitFeeParticular 
	SET IsPublished=@IsPublish,ModifiedBy=@UserId,ModifiedDate=@CurrentDateTime
	WHERE 
	AcademicYearId=@AcademicYearId AND GradeId=@GradeId 
	AND DivisionId=@DivisionId AND IsDeleted<>1;

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
@ErrorState 

END CATCH

END
