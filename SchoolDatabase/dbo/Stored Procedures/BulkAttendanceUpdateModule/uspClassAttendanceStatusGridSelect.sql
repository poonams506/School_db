--===============================================
-- Author:- Prerana Aher
-- Create date:- 03-09-2024
-- Description:- This stored procedure is used to get Class Attendance Status by GridSelect.
-- =============================================
CREATE PROCEDURE [dbo].[uspClassAttendanceStatusGridSelect]
(
    @RequestModel NVARCHAR(MAX)
)
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @CurrentDateTime DATETIME;
        SET @CurrentDateTime = GETDATE();

        DECLARE @AcademicYearId SMALLINT = JSON_VALUE(@RequestModel, '$.academicYearId');
        DECLARE @PageSize INT = JSON_VALUE(@RequestModel, '$.getListModel.length');
        DECLARE @PageNumber INT = JSON_VALUE(@RequestModel, '$.getListModel.start');
        DECLARE @SearchText NVARCHAR(150) = JSON_VALUE(@RequestModel, '$.getListModel.search.value');
        DECLARE @OrderBy INT = JSON_VALUE(@RequestModel, '$.getListModel.order[0].column');
        DECLARE @OrderBy_ASC_DESC NVARCHAR(20) = JSON_VALUE(@RequestModel, '$.getListModel.order[0].dir');

        DECLARE @MonthId INT = JSON_VALUE(@RequestModel, '$.monthId');
        DECLARE @YearId INT = JSON_VALUE(@RequestModel, '$.yearId');

        DECLARE @classIds TABLE(Id INT);  
        INSERT INTO @classIds
        SELECT VALUE FROM OPENJSON(@RequestModel, '$.classIds');

        DECLARE @classIdCount INT = (SELECT COUNT(Id) FROM @classIds);

        -- Get total count of matching records
        SELECT COUNT(s.SchoolGradeDivisionMatrixId)
        FROM SchoolGradeDivisionMatrix AS s
        INNER JOIN dbo.SchoolSetting AS ss ON s.AcademicYearId = ss.AcademicYearId AND ss.AcademicYearId = @AcademicYearId
        INNER JOIN dbo.Grade AS g ON g.GradeId = s.GradeId
        INNER JOIN dbo.Division AS d ON d.DivisionId = s.DivisionId
        CROSS JOIN (VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11)) AS n(Number)
        LEFT JOIN dbo.StudentAttendanceBulkSummaryStatus AS sa 
            ON sa.AcademicYearId = s.AcademicYearId
            AND sa.GradeId = s.GradeId
            AND sa.DivisionId = s.DivisionId
            AND sa.MonthId = MONTH(DATEADD(MONTH, n.Number, ss.AcademicYearStartMonth))
            AND sa.YearId = YEAR(DATEADD(MONTH, n.Number, ss.AcademicYearStartMonth))
        WHERE ISNULL(s.IsDeleted, 0) <> 1 
        AND (@classIdCount = 0 OR EXISTS (SELECT Id FROM @classIds WHERE Id = s.SchoolGradeDivisionMatrixId))
        AND DATEADD(MONTH, n.Number, ss.AcademicYearStartMonth) <= GETDATE()
        --AND (
        --    YEAR(DATEADD(MONTH, n.Number, ss.AcademicYearStartMonth)) = YEAR(GETDATE())
        --    OR YEAR(DATEADD(MONTH, n.Number, ss.AcademicYearStartMonth)) = YEAR(GETDATE()) - 1
        --)
        AND (LEN(@SearchText) = 0 
            OR LEN(@SearchText) > 0 AND (g.GradeName + ' - ' + d.DivisionName LIKE '%' + @SearchText + '%')
            OR LEN(@SearchText) > 0 AND (n.Number + '-' + ss.AcademicYearStartMonth LIKE '%' + @SearchText + '%')
        );

        -- Sorting and pagination logic
        IF (@OrderBy_ASC_DESC = 'desc')
        BEGIN
            SELECT 
                s.AcademicYearId,
                s.GradeId,
                g.GradeName,
                s.DivisionId,
                d.DivisionName,
                CASE
                    WHEN sa.IsCompleteStatus = 1 THEN 'Completed'
                    WHEN sa.IsCompleteStatus = '' OR sa.IsCompleteStatus IS NULL THEN 'Pending'
                END AS 'Status',
                CONCAT(g.GradeName, '-', d.DivisionName) AS ClassName,
                YEAR(DATEADD(MONTH, n.Number, ss.AcademicYearStartMonth)) AS 'Year',
                MONTH(DATEADD(MONTH, n.Number, ss.AcademicYearStartMonth)) AS 'MonthId',
                DATENAME(MONTH, DATEADD(MONTH, n.Number, ss.AcademicYearStartMonth)) + ' ' + 
                CAST(YEAR(DATEADD(MONTH, n.Number, ss.AcademicYearStartMonth)) AS VARCHAR(4)) AS 'Month'
            FROM SchoolGradeDivisionMatrix AS s
            INNER JOIN dbo.SchoolSetting AS ss ON s.AcademicYearId = ss.AcademicYearId AND ss.AcademicYearId = @AcademicYearId
            INNER JOIN dbo.Grade AS g ON g.GradeId = s.GradeId
            INNER JOIN dbo.Division AS d ON d.DivisionId = s.DivisionId
            CROSS JOIN (VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11)) AS n(Number)
            LEFT JOIN dbo.StudentAttendanceBulkSummaryStatus AS sa 
                ON sa.AcademicYearId = s.AcademicYearId
                AND sa.GradeId = s.GradeId
                AND sa.DivisionId = s.DivisionId
                AND sa.MonthId = MONTH(DATEADD(MONTH, n.Number, ss.AcademicYearStartMonth))
                AND sa.YearId = YEAR(DATEADD(MONTH, n.Number, ss.AcademicYearStartMonth))
            WHERE ISNULL(s.IsDeleted, 0) <> 1 
            AND (@classIdCount = 0 OR EXISTS (SELECT Id FROM @classIds WHERE Id = s.SchoolGradeDivisionMatrixId))
            AND DATEADD(MONTH, n.Number, ss.AcademicYearStartMonth) <= GETDATE()
            --AND (
            --    YEAR(DATEADD(MONTH, n.Number, ss.AcademicYearStartMonth)) = YEAR(GETDATE())
            --    OR YEAR(DATEADD(MONTH, n.Number, ss.AcademicYearStartMonth)) = YEAR(GETDATE()) - 1
            --)
            AND (LEN(@SearchText) = 0 
                OR LEN(@SearchText) > 0 AND (g.GradeName + ' - ' + d.DivisionName LIKE '%' + @SearchText + '%')
                OR LEN(@SearchText) > 0 AND (n.Number + '-' + ss.AcademicYearStartMonth LIKE '%' + @SearchText + '%')
            )
            ORDER BY 
                CASE WHEN @OrderBy = 0 THEN len(g.GradeName + ' - ' + d.DivisionName) END ASC, g.GradeName + ' - ' + d.DivisionName DESC,
                CASE WHEN @OrderBy = 1 THEN n.Number + ' ' + ss.AcademicYearStartMonth END DESC
            OFFSET @PageNumber ROWS
            FETCH NEXT @PageSize ROWS ONLY;
        END
        ELSE
        BEGIN
            SELECT 
                s.AcademicYearId,
                s.GradeId,
                g.GradeName,
                s.DivisionId,
                d.DivisionName,
                CASE
                    WHEN sa.IsCompleteStatus = 1 THEN 'Completed'
                    WHEN sa.IsCompleteStatus = '' OR sa.IsCompleteStatus IS NULL THEN 'Pending'
                END AS 'Status',
                CONCAT(g.GradeName, '-', d.DivisionName) AS ClassName,
                YEAR(DATEADD(MONTH, n.Number, ss.AcademicYearStartMonth)) AS 'Year',
                MONTH(DATEADD(MONTH, n.Number, ss.AcademicYearStartMonth)) AS 'MonthId',
                DATENAME(MONTH, DATEADD(MONTH, n.Number, ss.AcademicYearStartMonth)) + ' ' + 
                CAST(YEAR(DATEADD(MONTH, n.Number, ss.AcademicYearStartMonth)) AS VARCHAR(4)) AS 'Month'
            FROM SchoolGradeDivisionMatrix AS s
            INNER JOIN dbo.SchoolSetting AS ss ON s.AcademicYearId = ss.AcademicYearId AND ss.AcademicYearId = @AcademicYearId
            INNER JOIN dbo.Grade AS g ON g.GradeId = s.GradeId
            INNER JOIN dbo.Division AS d ON d.DivisionId = s.DivisionId
            CROSS JOIN (VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11)) AS n(Number)
            LEFT JOIN dbo.StudentAttendanceBulkSummaryStatus AS sa 
                ON sa.AcademicYearId = s.AcademicYearId
                AND sa.GradeId = s.GradeId
                AND sa.DivisionId = s.DivisionId
                AND sa.MonthId = MONTH(DATEADD(MONTH, n.Number, ss.AcademicYearStartMonth))
                AND sa.YearId = YEAR(DATEADD(MONTH, n.Number, ss.AcademicYearStartMonth))
            WHERE ISNULL(s.IsDeleted, 0) <> 1 
            AND (@classIdCount = 0 OR EXISTS (SELECT Id FROM @classIds WHERE Id = s.SchoolGradeDivisionMatrixId))
            AND DATEADD(MONTH, n.Number, ss.AcademicYearStartMonth) <= GETDATE()
            --AND (
            --    YEAR(DATEADD(MONTH, n.Number, ss.AcademicYearStartMonth)) = YEAR(GETDATE())
            --    OR YEAR(DATEADD(MONTH, n.Number, ss.AcademicYearStartMonth)) = YEAR(GETDATE()) - 1
            --)
            AND (LEN(@SearchText) = 0 
                OR LEN(@SearchText) > 0 AND (g.GradeName + ' - ' + d.DivisionName LIKE '%' + @SearchText + '%')
                OR LEN(@SearchText) > 0 AND (n.Number + '-' + ss.AcademicYearStartMonth LIKE '%' + @SearchText + '%')
            )
            ORDER BY 
                CASE WHEN @OrderBy = 0 THEN len(g.GradeName + ' - ' + d.DivisionName) END ASC, g.GradeName + ' - ' + d.DivisionName ASC,
                CASE WHEN @OrderBy = 1 THEN n.Number + ' ' + ss.AcademicYearStartMonth END ASC
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

        EXEC uspExceptionLogInsert
            @ErrorLine,
            @ErrorMessage,
            @ErrorNumber,
            @ErrorProcedure,
            @ErrorSeverity,
            @ErrorState;
    END CATCH
END

