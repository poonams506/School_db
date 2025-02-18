--===============================================
-- Author:- Gulave Pramod
-- Create date:- 24-07-2024
-- Description:- This stored procedure is used to get Class Exam Mapping info detail by Select
-- =============================================
CREATE PROCEDURE uspClassExamMappingSelect
(
	@ClassExamMappingId BIGINT=NULL
)
AS 
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;
    
    BEGIN TRY 

SELECT
    em.ClassExamMappingId,
	em.AcademicYearId,
	e.ExamName,
    sgdm.SchoolGradeDivisionMatrixId AS 'ClassId'


FROM
	CBSE_ClassExamMapping AS em
	INNER JOIN CBSE_ExamMaster as e on em.ExamMasterId = e.ExamMasterId
    INNER JOIN dbo.SchoolGradeDivisionMatrix sgdm ON em.GradeId = sgdm.GradeId AND em.DivisionId = sgdm.DivisionId AND em.AcademicYearId = sgdm.AcademicYearId


WHERE
	em.ClassExamMappingId = @ClassExamMappingId
	AND em.IsDeleted <> 1	
	
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
            @ErrorState;
    END CATCH
END