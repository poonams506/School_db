-- =============================================
-- Author: POONAM BHALKE
-- Create date: 07/03/2024
-- Description: This stored procedure is used for doing SchoolVacation Upsert
-- =============================================
CREATE PROCEDURE [dbo].[uspSchoolVacationUpsert]
	@SchoolVacationId BIGINT,
	@AcademicYearId SMALLINT,
	@VacationName NVARCHAR(100),
	@StartDate DATETIME,
	@EndDate DATETIME,
	@UserId INT
AS 
BEGIN 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;

	DECLARE @CurrentDateTime DATETIME = GETDATE();

	BEGIN TRY 
		BEGIN TRANSACTION;

		IF @SchoolVacationId > 0 
		BEGIN
			UPDATE SchoolVacation
			SET 
			    [AcademicYearId] = @AcademicYearId,
				[VacationName] = @VacationName,
				[StartDate] = @StartDate,
				[EndDate] = @EndDate,
				[ModifiedBy] = @UserId, 
				[ModifiedDate] = @CurrentDateTime
			WHERE 
				[SchoolVacationId] = @SchoolVacationId;
		END
		ELSE 
		BEGIN
			INSERT INTO SchoolVacation
				(
				    [AcademicYearId],
					[VacationName],
					[StartDate], 
					[EndDate],
					[CreatedBy],
                    [CreatedDate]
				)
			VALUES
			   (
			        @AcademicYearId,
					@VacationName, 
					@StartDate, 
					@EndDate,
					@UserId, 
					@CurrentDateTime
				);
		END;

		COMMIT;
	END TRY

	BEGIN CATCH
		ROLLBACK;

		DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
		DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
		DECLARE @ErrorState INT = ERROR_STATE();
		DECLARE @ErrorNumber INT = ERROR_NUMBER();
		DECLARE @ErrorLine INT = ERROR_LINE();
		DECLARE @ErrorProcedure NVARCHAR(1000) = ERROR_PROCEDURE();

		EXEC uspExceptionLogInsert 
			@ErrorLine = @ErrorLine, 
			@ErrorMessage = @ErrorMessage, 
			@ErrorNumber = @ErrorNumber, 
			@ErrorProcedure = @ErrorProcedure, 
			@ErrorSeverity = @ErrorSeverity, 
			@ErrorState = @ErrorState;

		THROW;
	END CATCH;
END;
