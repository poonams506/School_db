-- =============================================
-- Author: Saurabh Walunj 
-- Create date: 25/07/2024
-- Description:  This stored procedure is used to get Exam Object info in Grid
-- =============================================
CREATE PROCEDURE [dbo].[uspExamObjectGridSelect](@RequestModel NVARCHAR(MAX)) 
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    BEGIN TRY
        -- Extract parameters from JSON input
        DECLARE @AcademicYearId SMALLINT = JSON_VALUE(@RequestModel, '$.academicYearId');
        DECLARE @PageSize INT = JSON_VALUE(@RequestModel, '$.getListModel.length');
        DECLARE @PageNumber INT = JSON_VALUE(@RequestModel, '$.getListModel.start');
        DECLARE @SearchText NVARCHAR(150) = JSON_VALUE(@RequestModel, '$.getListModel.search.value');
        DECLARE @OrderBy INT = JSON_VALUE(@RequestModel, '$.getListModel.order[0].column');
        DECLARE @OrderBy_ASC_DESC NVARCHAR(20) = JSON_VALUE(@RequestModel, '$.getListModel.order[0].dir');

        -- Get total count of unique records for pagination
        SELECT COUNT(DISTINCT CONCAT(eo.ExamMasterId, '_', eo.SubjectMasterId)) AS TotalRecords
        FROM CBSE_ExamObject eo
        INNER JOIN CBSE_ExamMaster em ON eo.ExamMasterId = em.ExamMasterId
        INNER JOIN SubjectMaster sm ON eo.SubjectMasterId = sm.SubjectMasterId
        WHERE eo.AcademicYearId = @AcademicYearId
          AND ISNULL(eo.IsDeleted, 0) <> 1
          AND ISNULL(em.IsDeleted, 0) <> 1
          AND ISNULL(sm.IsDeleted, 0) <> 1
          AND (
              LEN(@SearchText) = 0
              OR sm.SubjectName LIKE '%' + @SearchText + '%'
              OR em.ExamName LIKE '%' + @SearchText + '%'
              OR eo.ObjectName LIKE '%' + @SearchText + '%'
              OR CAST(eo.OutOfMarks AS NVARCHAR) LIKE '%' + @SearchText + '%'
          );

        -- Main query to fetch paginated records
        IF (@OrderBy_ASC_DESC = 'desc')
        BEGIN
            SELECT 
                MIN(eo.ExamObjectId) AS ExamObjectId, 
                sm.SubjectName,
                eo.SubjectMasterId,
                em.ExamName AS Name,
                em.ExamMasterId,
                STUFF((
                    SELECT DISTINCT ', ' + CONCAT(ceo.ObjectName, '(', ceo.OutOfMarks, ')')
                    FROM CBSE_ExamObject ceo
                    WHERE ceo.ExamMasterId = em.ExamMasterId
                      AND ceo.SubjectMasterId = eo.SubjectMasterId
                      AND ISNULL(ceo.IsDeleted, 0) <> 1
                    FOR XML PATH(''), TYPE
                ).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS ObjectName
            FROM CBSE_ExamObject eo
            INNER JOIN CBSE_ExamMaster em ON eo.ExamMasterId = em.ExamMasterId
            INNER JOIN SubjectMaster sm ON eo.SubjectMasterId = sm.SubjectMasterId
            WHERE eo.AcademicYearId = @AcademicYearId
              AND ISNULL(eo.IsDeleted, 0) <> 1
              AND ISNULL(em.IsDeleted, 0) <> 1
              AND ISNULL(sm.IsDeleted, 0) <> 1
              AND (
                  LEN(@SearchText) = 0
                  OR sm.SubjectName LIKE '%' + @SearchText + '%'
                  OR em.ExamName LIKE '%' + @SearchText + '%'
                  OR eo.ObjectName LIKE '%' + @SearchText + '%'
                  OR CAST(eo.OutOfMarks AS NVARCHAR) LIKE '%' + @SearchText + '%'
              )
            GROUP BY 
                sm.SubjectName,
                eo.SubjectMasterId,
                em.ExamName,
                em.ExamMasterId
            ORDER BY
                CASE WHEN @OrderBy = 0 THEN sm.SubjectName END DESC,
                CASE WHEN @OrderBy = 1 THEN em.ExamName END DESC
            OFFSET @PageNumber ROWS
            FETCH NEXT @PageSize ROWS ONLY;
        END
        ELSE
        BEGIN
            SELECT 
                MIN(eo.ExamObjectId) AS ExamObjectId, 
                sm.SubjectName,
                eo.SubjectMasterId,
                em.ExamName AS Name,
                em.ExamMasterId,
                STUFF((
                    SELECT DISTINCT ', ' + CONCAT(ceo.ObjectName, '(', ceo.OutOfMarks, ')')
                    FROM CBSE_ExamObject ceo
                    WHERE ceo.ExamMasterId = em.ExamMasterId
                      AND ceo.SubjectMasterId = eo.SubjectMasterId
                      AND ISNULL(ceo.IsDeleted, 0) <> 1
                    FOR XML PATH(''), TYPE
                ).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS ObjectName
            FROM CBSE_ExamObject eo
            INNER JOIN CBSE_ExamMaster em ON eo.ExamMasterId = em.ExamMasterId
            INNER JOIN SubjectMaster sm ON eo.SubjectMasterId = sm.SubjectMasterId
            WHERE eo.AcademicYearId = @AcademicYearId
              AND ISNULL(eo.IsDeleted, 0) <> 1
              AND ISNULL(em.IsDeleted, 0) <> 1
              AND ISNULL(sm.IsDeleted, 0) <> 1
              AND (
                  LEN(@SearchText) = 0
                  OR sm.SubjectName LIKE '%' + @SearchText + '%'
                  OR em.ExamName LIKE '%' + @SearchText + '%'
                  OR eo.ObjectName LIKE '%' + @SearchText + '%'
                  OR CAST(eo.OutOfMarks AS NVARCHAR) LIKE '%' + @SearchText + '%'
              )
            GROUP BY 
                sm.SubjectName,
                eo.SubjectMasterId,
                em.ExamName,
                em.ExamMasterId
            ORDER BY
                CASE WHEN @OrderBy = 0 THEN sm.SubjectName END ASC,
                CASE WHEN @OrderBy = 1 THEN em.ExamName END ASC
            OFFSET @PageNumber ROWS
            FETCH NEXT @PageSize ROWS ONLY;
        END

    END TRY
    BEGIN CATCH
        -- Log and handle errors
        DECLARE @ErrorMessage NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        DECLARE @ErrorNumber INT = ERROR_NUMBER();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProcedure NVARCHAR(128) = ERROR_PROCEDURE();

        EXEC uspExceptionLogInsert 
            @ErrorLine, 
            @ErrorMessage, 
            @ErrorNumber, 
            @ErrorProcedure, 
            @ErrorSeverity, 
            @ErrorState;
    END CATCH
END
