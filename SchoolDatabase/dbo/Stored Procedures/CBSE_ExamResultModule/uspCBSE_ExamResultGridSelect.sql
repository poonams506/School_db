--=============================================
-- Author Name:  Gulave Pramod
-- Create date:  03-09-2024
-- Description:  This stored procedure is used to get class exam mapping info
-- =============================================
CREATE PROCEDURE [dbo].[uspCBSE_ExamResultGridSelect] (@RequestModel NVARCHAR(MAX)) 
AS 
BEGIN 
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @AcademicYearId SMALLINT = JSON_VALUE(@RequestModel, '$.academicYearId');
        DECLARE @GradeId SMALLINT = JSON_VALUE(@RequestModel, '$.gradeId');
        DECLARE @DivisionId SMALLINT = JSON_VALUE(@RequestModel, '$.divisionId');
        DECLARE @ExamMasterId SMALLINT = JSON_VALUE(@RequestModel, '$.examMasterId');
        DECLARE @SubjectMasterId INT = JSON_VALUE(@RequestModel, '$.subjectMasterId');
        DECLARE @PageSize INT = JSON_VALUE(@RequestModel, '$.getListModel.length');
        DECLARE @PageNumber INT = JSON_VALUE(@RequestModel, '$.getListModel.start');
        DECLARE @SearchText NVARCHAR(150) = JSON_VALUE(@RequestModel, '$.getListModel.search.value');
        DECLARE @OrderBy INT = JSON_VALUE(@RequestModel, '$.getListModel.order[0].column');
        DECLARE @OrderBy_ASC_DESC NVARCHAR(20) = JSON_VALUE(@RequestModel, '$.getListModel.order[0].dir');

        WITH CTE_ExamResultCount AS (
            SELECT DISTINCT
                g.GradeName + ' - ' + d.DivisionName AS ClassName,
                g.GradeId,
                d.DivisionId,
                e.ExamMasterId,
                e.ExamName,
                eo.SubjectMasterId,
                sm.SubjectName
            FROM 
                CBSE_ClassExamMapping em
                INNER JOIN Grade g ON em.GradeId = g.GradeId
                INNER JOIN Division d ON em.DivisionId = d.DivisionId
                INNER JOIN CBSE_ExamMaster e ON em.ExamMasterId = e.ExamMasterId
                INNER JOIN CBSE_ExamObject eo ON e.ExamMasterId = eo.ExamMasterId
                INNER JOIN SubjectMaster sm ON eo.SubjectMasterId = sm.SubjectMasterId
            WHERE
                em.AcademicYearId = @AcademicYearId
                AND ISNULL(em.IsDeleted, 0) <> 1 
                AND ISNULL(eo.IsDeleted, 0) <> 1 
                AND ISNULL(e.IsDeleted, 0) <> 1
                AND ISNULL(sm.IsDeleted, 0) <> 1   
                AND (em.GradeId = ISNULL(@GradeId, em.GradeId))
                AND (em.DivisionId = ISNULL(@DivisionId, em.DivisionId))
                AND (em.ExamMasterId = ISNULL(@ExamMasterId, em.ExamMasterId))
                AND (sm.SubjectMasterId = ISNULL(@SubjectMasterId, sm.SubjectMasterId))
                AND (LEN(@SearchText) = 0 
                    OR (LEN(@SearchText) > 0 AND (g.GradeName + ' - ' + d.DivisionName LIKE '%' + @SearchText + '%'))
                    OR (LEN(@SearchText) > 0 AND (e.ExamName LIKE '%' + @SearchText + '%'))
                    OR (LEN(@SearchText) > 0 AND (sm.SubjectName LIKE '%' + @SearchText + '%')))
        )
        -- Get Total Count
        SELECT COUNT(*) AS TotalCount FROM CTE_ExamResultCount;

        -- Main Query
        IF (@OrderBy_ASC_DESC = 'desc')
        BEGIN
            SELECT *
            FROM (
                SELECT DISTINCT
                    g.GradeName + ' - ' + d.DivisionName AS ClassName,
                    g.GradeId,
                    d.DivisionId,
                    e.ExamMasterId,
                    e.ExamName,
                    eo.SubjectMasterId,
                    sm.SubjectName
                FROM 
                    CBSE_ClassExamMapping em
                    INNER JOIN Grade g ON em.GradeId = g.GradeId
                    INNER JOIN Division d ON em.DivisionId = d.DivisionId
                    INNER JOIN CBSE_ExamMaster e ON em.ExamMasterId = e.ExamMasterId
                    INNER JOIN CBSE_ExamObject eo ON e.ExamMasterId = eo.ExamMasterId
                    INNER JOIN SubjectMaster sm ON eo.SubjectMasterId = sm.SubjectMasterId
                WHERE
                    em.AcademicYearId = @AcademicYearId
                    AND ISNULL(em.IsDeleted, 0) <> 1 
                    AND ISNULL(eo.IsDeleted, 0) <> 1 
                    AND ISNULL(e.IsDeleted, 0) <> 1
                    AND (em.GradeId = ISNULL(@GradeId, em.GradeId) OR em.GradeId = @GradeId)  
                    AND (em.DivisionId = ISNULL(@DivisionId, em.DivisionId) OR em.DivisionId = @DivisionId)
                    AND (em.ExamMasterId = ISNULL(@ExamMasterId, em.ExamMasterId) OR em.ExamMasterId = @ExamMasterId)  
                    AND (sm.SubjectMasterId = ISNULL(@SubjectMasterId, sm.SubjectMasterId) OR sm.SubjectMasterId = @SubjectMasterId)
                    AND (LEN(@SearchText) = 0 
                    OR (LEN(@SearchText) > 0 AND (g.GradeName+'-'+d.DivisionName LIKE '%' + @SearchText + '%'))
                    OR (LEN(@SearchText) > 0 AND (e.ExamName LIKE '%' + @SearchText + '%'))
                    OR (LEN(@SearchText) > 0 AND (sm.SubjectName LIKE '%' + @SearchText + '%'))
                    )
            ) AS Subquery
            ORDER BY
                CASE WHEN @OrderBy = 0 THEN len(ClassName) END DESC, ClassName DESC, 
                CASE WHEN @OrderBy = 1 THEN ExamName END DESC,
                CASE WHEN @OrderBy = 2 THEN SubjectName END DESC
            OFFSET @PageNumber ROWS
            FETCH NEXT @PageSize ROWS ONLY;
        END
        ELSE
        BEGIN
            SELECT *
            FROM (
                SELECT DISTINCT
                    g.GradeName + ' - ' + d.DivisionName AS ClassName,
                    g.GradeId,
                    d.DivisionId,
                    e.ExamMasterId,
                    e.ExamName,
                    eo.SubjectMasterId,
                    sm.SubjectName
                FROM 
                    CBSE_ClassExamMapping em
                    INNER JOIN Grade g ON em.GradeId = g.GradeId
                    INNER JOIN Division d ON em.DivisionId = d.DivisionId
                    INNER JOIN CBSE_ExamMaster e ON em.ExamMasterId = e.ExamMasterId
                    INNER JOIN CBSE_ExamObject eo ON e.ExamMasterId = eo.ExamMasterId
                    INNER JOIN SubjectMaster sm ON eo.SubjectMasterId = sm.SubjectMasterId
                WHERE
                    em.AcademicYearId = @AcademicYearId
                    AND ISNULL(em.IsDeleted, 0) <> 1 
                    AND ISNULL(eo.IsDeleted, 0) <> 1 
                    AND ISNULL(e.IsDeleted, 0) <> 1
                    AND (em.GradeId = ISNULL(@GradeId, em.GradeId) OR em.GradeId = @GradeId)  
                    AND (em.DivisionId = ISNULL(@DivisionId, em.DivisionId) OR em.DivisionId = @DivisionId)
                    AND (em.ExamMasterId = ISNULL(@ExamMasterId, em.ExamMasterId) OR em.ExamMasterId = @ExamMasterId)  
                    AND (sm.SubjectMasterId = ISNULL(@SubjectMasterId, sm.SubjectMasterId) OR sm.SubjectMasterId = @SubjectMasterId)
                    AND (LEN(@SearchText) = 0 
                    OR (LEN(@SearchText) > 0 AND (g.GradeName+'-'+d.DivisionName LIKE '%' + @SearchText + '%'))
                    OR (LEN(@SearchText) > 0 AND (e.ExamName LIKE '%' + @SearchText + '%'))
                    OR (LEN(@SearchText) > 0 AND (sm.SubjectName LIKE '%' + @SearchText + '%'))
                    )
            ) AS Subquery
            ORDER BY
                CASE WHEN @OrderBy = 0 THEN len(ClassName) END ASC, ClassName ASC,
                CASE WHEN @OrderBy = 1 THEN ExamName END ASC,
                CASE WHEN @OrderBy = 2 THEN SubjectName END ASC
            OFFSET @PageNumber ROWS
            FETCH NEXT @PageSize ROWS ONLY;
        END 
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
    END CATCH;
END
