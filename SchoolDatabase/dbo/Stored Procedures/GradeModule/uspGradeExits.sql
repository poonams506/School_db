-- =============================================
-- Author:    Meena Kotkar
-- Create date: 22/11/2023
-- Description:  This stored procedure is used delete Grade data
-- =============================================
CREATE PROCEDURE [dbo].[uspGradeExits] (
  @GradeId INT = NULL,
  @AcademicYearId INT
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 

 
  DECLARE @CurrentDateTime DATETIME = GETDATE();
    DECLARE @StudentCount INT;
		SELECT @StudentCount = COUNT(GradeId)
	FROM SchoolGradeDivisionMatrix
	WHERE GradeId = @GradeId and AcademicYearId = @AcademicYearId and IsDeleted<>1;
	
	IF @StudentCount<1
	BEGIN
		SELECT @StudentCount =  @StudentCount +COUNT(GradeId)
		FROM StudentGradeDivisionMapping
		WHERE GradeId = @GradeId and AcademicYearId = @AcademicYearId and IsDeleted<>1;
	END

BEGIN TRY IF @StudentCount >0 
	BEGIN 
		RETURN @StudentCount;
	 END
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



