-- =============================================
-- Author:        Saurabh Walunj
-- Create date:   28/08/2024
-- Description:   This stored procedure is used to get Exam Report Card by Select
-- =============================================
CREATE PROC [dbo].[uspExamReportCardSelect] 
(
   @ExamReportCardNameId BIGINT,
   @AcademicYearId INT = NULL
)
AS 
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    BEGIN TRY
         SELECT DISTINCT
	er.ExamReportCardNameId,
	er.ReportCardName,
	er.Description,
    STUFF(
        (
            SELECT  
                ', ' + em2.ExamName
            FROM CBSE_ReportCardExam rcm2
            INNER JOIN CBSE_Term t2 ON rcm2.TermId = t2.TermId
            INNER JOIN CBSE_ExamMaster em2 ON rcm2.ExamMasterId = em2.ExamMasterId
            WHERE 
			--rcm2.TermId = rcm.TermId 
             rcm2.ExamReportCardNameId = er.ExamReportCardNameId
            FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)')
    , 1, 2, '') AS ExamNames,
    er.IsTwoDifferentExamSection,
    (
        SELECT STRING_AGG(CAST(sgdm.SchoolGradeDivisionMatrixId AS NVARCHAR(10)), ', ')
        FROM CBSE_ReportCardClasses rcc
        INNER JOIN SchoolGradeDivisionMatrix sgdm ON sgdm.GradeId = rcc.GradeId 
        AND sgdm.DivisionId = rcc.DivisionId 
        WHERE ISNULL(rcc.IsDeleted, 0) = 0 
        AND ISNULL(sgdm.IsDeleted, 0) = 0
        AND rcc.ExamReportCardNameId = er.ExamReportCardNameId
        AND sgdm.AcademicYearId = @AcademicYearId
        AND rcc.AcademicYearId = @AcademicYearId
    ) AS ClassIds,
	(
        SELECT STRING_AGG(CAST(rcm2.ExamMasterId AS NVARCHAR(10)), ', ')
        FROM CBSE_ReportCardExam rcm2
        INNER JOIN CBSE_ExamMaster em2 ON rcm2.ExamMasterId = em2.ExamMasterId
        WHERE ISNULL(em2.IsDeleted, 0) = 0 
        AND ISNULL(rcm2.IsDeleted, 0) = 0
        AND rcm2.ExamReportCardNameId = er.ExamReportCardNameId
    ) AS ExamIds
FROM CBSE_ExamReportCardName er
INNER JOIN CBSE_ReportCardExam rcm ON er.ExamReportCardNameId = rcm.ExamReportCardNameId
INNER JOIN CBSE_Term t ON rcm.TermId = t.TermId
INNER JOIN CBSE_ExamMaster em ON rcm.ExamMasterId = em.ExamMasterId
INNER JOIN CBSE_ReportCardClasses cm ON er.ExamReportCardNameId = cm.ExamReportCardNameId
INNER JOIN Grade g ON cm.GradeId = g.GradeId
INNER JOIN Division d ON cm.DivisionId = d.DivisionId

WHERE
er.IsDeleted <> 1
AND er.ExamReportCardNameId = @ExamReportCardNameId
AND er.AcademicYearId = @AcademicYearId
GROUP BY
    er.ReportCardName,
	er.Description,
    rcm.ExamMasterId,
    er.IsTwoDifferentExamSection,
    er.ExamReportCardNameId


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



