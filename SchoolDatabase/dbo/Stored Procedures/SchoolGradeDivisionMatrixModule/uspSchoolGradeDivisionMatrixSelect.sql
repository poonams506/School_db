-- =============================================
-- Author:    Abhishek Kumar
-- Create date: 23/08/2023
-- Description:  This stored procedure is used to get school grade division matrix info detail by Id
-- =============================================
CREATE PROC uspSchoolGradeDivisionMatrixSelect(@GradeId INT = NULL,
 @AcademicYearId INT
) AS 
Begin 
	SET 
	  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET 
	  NOCOUNT ON;
	BEGIN TRY 

		SELECT 
		g.GradeId,
		g.GradeName,
		DivisionId
		FROM 
		 SchoolGradeDivisionMatrix sgdm 
		 JOIN Grade g ON sgdm.GradeId=g.GradeId
		WHERE 
		 g.GradeId = ISNULL(@GradeId, g.GradeId) AND sgdm.IsDeleted<>1 AND sgdm.AcademicYearId = @AcademicYearId
		 
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
End
