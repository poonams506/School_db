--===============================================
-- Author:    Prerana Aher
-- Create date: 02/08/2024
-- Description:  Select Stored Procedure for Exam Type info detail by Select
-- =============================================
CREATE PROCEDURE [dbo].[uspExamMasterDropdown]
(
@AcademicYearId SMALLINT
)
AS 
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;
    
    BEGIN TRY 

SELECT
e.ExamMasterId,
e.ExamName,
e.TermId

FROM
	  CBSE_ExamMaster as e
	  INNER JOIN CBSE_Term ct ON e.TermId=ct.TermId

        WHERE
		     e.AcademicYearId=@AcademicYearId AND
	         e.IsDeleted <> 1 AND
			 ct.IsDeleted <> 1

			 ORDER BY e.ExamName
           
	
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