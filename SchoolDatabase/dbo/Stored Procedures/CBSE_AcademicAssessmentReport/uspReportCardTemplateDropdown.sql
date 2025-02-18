--===============================================
-- Author:    Prerana Aher
-- Create date: 28/10/2024
-- Description:  This stored procedure is used to get report card template name dropdown select by Student 
-- =============================================
CREATE PROCEDURE [dbo].[uspReportCardTemplateDropdown]
(
@AcademicYearId SMALLINT,
@GradeId SMALLINT,
@DivisionId SMALLINT
)
AS 
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;
    
    BEGIN TRY 

	SELECT
	 er.ExamReportCardNameId,
	 er.ReportCardName

	FROM
	  CBSE_ExamReportCardName er
	  INNER JOIN CBSE_ReportCardClasses rc ON er.ExamReportCardNameId=rc.ExamReportCardNameId

    WHERE
	  er.AcademicYearId =  @AcademicYearId
	  AND rc.GradeId=@GradeId
	  AND rc.DivisionId=@DivisionId
	  AND er.IsDeleted <> 1 

	
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

