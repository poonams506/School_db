-- =============================================
-- Author:    Poonam Bahlke
-- Create date: 08/04/2024
-- Description:  This stored procedure is used to Get Publish/Unpublish Suvey data
-- =============================================
CREATE PROCEDURE [dbo].[uspSurveyPublishUpdate]
(
	@SurveyId BIGINT,
	@IsPublished BIT,
	@UserId INT
)

AS BEGIN 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;

	DECLARE @CurrentDateTime DATETIME = GETDATE();

	BEGIN TRY 
		UPDATE Survey
		SET 
			IsPublished = @IsPublished,
			ModifiedBy = @UserId,
			ModifiedDate = @CurrentDateTime 
		WHERE SurveyId = @SurveyId
			AND IsDeleted <> 1;
	END TRY

	BEGIN CATCH 
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
	END CATCH

END

