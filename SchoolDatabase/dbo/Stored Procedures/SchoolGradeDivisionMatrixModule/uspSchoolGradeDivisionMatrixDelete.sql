-- =============================================
-- Author:    Meena Kotkar
-- Create date: 28/11/2023
-- Description:  This stored procedure is used delete Division data
-- =============================================
CREATE PROCEDURE [dbo].[uspSchoolGradeDivisionMatrixDelete] (
  @GradeId INT = NULL,
  @DivisionName NVARCHAR(200),
  @AcademicYearId INT,
  @UserId INT
) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
SET 
  NOCOUNT ON 

  DECLARE @DivisionId INT;
  SET @DivisionId = (SELECT TOP 1 DivisionId FROM Division WHERE DivisionName = TRIM(@DivisionName) AND IsDeleted=0);
  DECLARE @CurrentDateTime DATETIME = GETDATE();
	 DECLARE @Count INT;
	    
		with cte1 AS (
		SELECT COUNT(GradeId) as Total
		FROM StudentGradeDivisionMapping
		WHERE GradeId = @GradeId AND DivisionId = @DivisionId AND AcademicYearId = @AcademicYearId
		UNION
		SELECT COUNT(GradeId) as Total
		FROM CertificateAudits
		WHERE GradeId = @GradeId AND DivisionId = @DivisionId  AND AcademicYearId = @AcademicYearId
		UNION
		SELECT COUNT(GradeId) as Total
		FROM FeeParticular
		WHERE GradeId = @GradeId AND DivisionId = @DivisionId AND AcademicYearId = @AcademicYearId
		UNION
		SELECT COUNT(GradeId) as Total
		FROM FeeParticularWavierMapping
		WHERE GradeId = @GradeId AND DivisionId = @DivisionId AND AcademicYearId = @AcademicYearId
		UNION
		SELECT COUNT(GradeId) as Total
		FROM StudentAttendance
		WHERE GradeId = @GradeId AND DivisionId = @DivisionId AND AcademicYearId = @AcademicYearId
		UNION
		SELECT COUNT(GradeId) as Total
		FROM SubjectMapping
		WHERE GradeId = @GradeId AND DivisionId = @DivisionId AND AcademicYearId = @AcademicYearId
		UNION
		SELECT COUNT(GradeId) as Total
		FROM CBSE_ClassExamMapping
		WHERE GradeId = @GradeId AND DivisionId = @DivisionId AND AcademicYearId = @AcademicYearId)

		SELECT @Count = SUM(Total) FROM cte1
	
	IF @Count = 0
  BEGIN
    BEGIN TRY
      UPDATE SchoolGradeDivisionMatrix 
		SET IsDeleted=1,
		ModifiedBy=@UserId,
		ModifiedDate=@CurrentDateTime
      WHERE GradeId = @GradeId AND DivisionId = @DivisionId  AND AcademicYearId = @AcademicYearId;
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
  ELSE
  BEGIN
    -- Return 0 if the Grade does not exist
    SELECT 0 AS 'AffectedRows';
  END
END