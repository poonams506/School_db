--===============================================
-- Author:    Prerana Aher
-- Create date: 28/10/2024   
-- Description:  This stored procedure is used to get Result Template report by Term
-- =============================================
CREATE PROC [dbo].[uspResultTempleteReportSearchSelect](
    @StudentId SMALLINT,
    @AcademicYearId SMALLINT,
    @GradeId SMALLINT,
    @DivisionId SMALLINT,
    @ExamReportCardNameId BIGINT
)
AS 
BEGIN 
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    BEGIN TRY 
        SELECT 
            erc.ReportCardName,
            et.ExamTypeName,
            em.TermId,
            t.TermName,
            em.ExamName,
            sm.SubjectName,
            s.IndexNumber,
            eo.ObjectName,
            e.OutOfMarks,
            e.ActualMarks,
            e.TotalMarks,
            e.Grade,
            erc.IsTwoDifferentExamSection
        FROM
            CBSE_ExamResult e
            INNER JOIN CBSE_ExamObject eo ON e.ExamObjectId = eo.ExamObjectId
            INNER JOIN CBSE_ExamMaster em ON eo.ExamMasterId = em.ExamMasterId
            INNER JOIN CBSE_ClassExamMapping cem ON em.ExamMasterId = cem.ExamMasterId
            INNER JOIN CBSE_ReportCardExam er ON em.ExamMasterId = er.ExamMasterId
            INNER JOIN CBSE_ExamReportCardName erc ON er.ExamReportCardNameId = erc.ExamReportCardNameId
            INNER JOIN SubjectMaster sm ON eo.SubjectMasterId = sm.SubjectMasterId
            INNER JOIN SubjectMapping s ON sm.SubjectMasterId = s.SubjectMasterId AND cem.GradeId = s.GradeId AND cem.DivisionId = s.DivisionId
            INNER JOIN CBSE_ExamType et ON em.ExamTypeId = et.ExamTypeId
            INNER JOIN CBSE_Term t ON em.TermId = t.TermId
        WHERE
            e.AcademicYearId=@AcademicYearId
            AND eo.AcademicYearId=@AcademicYearId
            AND cem.AcademicYearId=@AcademicYearId
            AND erc.AcademicYearId=@AcademicYearId
            AND s.AcademicYearId=@AcademicYearId
            AND er.ExamReportCardNameId = @ExamReportCardNameId
            AND e.StudentId = @StudentId
            AND cem.GradeId = @GradeId
            AND cem.DivisionId = @DivisionId
            AND e.IsDeleted<>1
            AND cem.IsDeleted<>1
            AND sm.IsDeleted <>1
            AND s.IsDeleted<>1
            AND er.IsDeleted <> 1
            AND em.IsDeleted <> 1
            AND er.AcademicYearId = @AcademicYearId
            AND em.TermId = 1 
        ORDER BY s.IndexNumber, et.ExamTypeName ASC;
		         

        SELECT 
            erc.ReportCardName,
            et.ExamTypeName,
            em.TermId,
            t.TermName,
            em.ExamName,
            sm.SubjectName,
            s.IndexNumber,
            eo.ObjectName,
            e.OutOfMarks,
            e.ActualMarks,
            e.TotalMarks,
            e.Grade,
            erc.IsTwoDifferentExamSection
        FROM
            CBSE_ExamResult e
            INNER JOIN CBSE_ExamObject eo ON e.ExamObjectId = eo.ExamObjectId
            INNER JOIN CBSE_ExamMaster em ON eo.ExamMasterId = em.ExamMasterId
            INNER JOIN CBSE_ClassExamMapping cem ON em.ExamMasterId = cem.ExamMasterId
            INNER JOIN CBSE_ReportCardExam er ON em.ExamMasterId = er.ExamMasterId
            INNER JOIN CBSE_ExamReportCardName erc ON er.ExamReportCardNameId = erc.ExamReportCardNameId
            INNER JOIN SubjectMaster sm ON eo.SubjectMasterId = sm.SubjectMasterId
            INNER JOIN SubjectMapping s ON sm.SubjectMasterId = s.SubjectMasterId AND cem.GradeId = s.GradeId AND cem.DivisionId = s.DivisionId
            INNER JOIN CBSE_ExamType et ON em.ExamTypeId = et.ExamTypeId
            INNER JOIN CBSE_Term t ON em.TermId = t.TermId
        WHERE e.AcademicYearId=@AcademicYearId
            AND eo.AcademicYearId=@AcademicYearId
            AND cem.AcademicYearId=@AcademicYearId
            AND erc.AcademicYearId=@AcademicYearId
            AND s.AcademicYearId=@AcademicYearId
            AND er.ExamReportCardNameId = @ExamReportCardNameId
            AND e.StudentId = @StudentId
            AND cem.GradeId = @GradeId
            AND cem.DivisionId = @DivisionId
            AND er.IsDeleted <> 1
            AND em.IsDeleted <> 1
            AND er.AcademicYearId = @AcademicYearId
            AND em.TermId = 2 
        ORDER BY s.IndexNumber, et.ExamTypeName ASC;

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
END;
