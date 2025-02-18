--===============================================
-- Author:    Prerana Aher
-- Create date: 25/7/2024
-- Description:  This stored procedure is used to get Exam Master info detail by Select 
-- =============================================
CREATE PROCEDURE [dbo].[uspExamMasterSelect]
(
	@ExamMasterId SMALLINT
)
AS 
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;
    
    BEGIN TRY 

SELECT
em.ExamMasterId,
em.AcademicYearId,
em.ExamName,
em.ExamTypeId,
et.ExamTypeName,
em.TermId,
t.TermName

FROM
	  CBSE_ExamMaster AS em
	  INNER JOIN CBSE_Term AS t on em.TermId = t.TermId
	  INNER JOIN CBSE_ExamType As et on em.ExamTypeId = et.ExamTypeId

        WHERE
			em.ExamMasterId = @ExamMasterId
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



--uspExamMasterSelect 3