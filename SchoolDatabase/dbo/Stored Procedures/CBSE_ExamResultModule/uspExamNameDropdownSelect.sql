-- =============================================
-- Author:    Prathamesh Ghule
-- Create date: 27/08/2024
-- Description:  This stored procedure is used to get ExamName dropdown from classId
-- =============================================
CREATE PROC uspExamNameDropdownSelect 
(
@AcademicYearId int = null,
@GradeId int=null,
@DivisionId int= null
)
AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 
SELECT Distinct
		  cem.ClassExamMappingId,
		  em.ExamMasterId,
		  em.ExamName

        FROM CBSE_ExamMaster  AS em
		INNER JOIN  CBSE_ClassExamMapping AS cem ON em.ExamMasterId = cem.ExamMasterId
		INNER JOIN Grade AS g ON cem.GradeId = g.GradeId
		INNER JOIN Division AS d ON cem.DivisionId = d.DivisionId

        WHERE 
		cem.GradeId = @GradeId
		AND cem.DivisionId = @DivisionId
		AND em.AcademicYearId=@AcademicYearId
		AND cem.IsDeleted <> 1
		AND em.IsDeleted<>1;
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
@ErrorState END CATCH End