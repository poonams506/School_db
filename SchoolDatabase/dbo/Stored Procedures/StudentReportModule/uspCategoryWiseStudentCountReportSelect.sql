-- =============================================
-- Author:   POONAM BHALKE
-- Create date: 07/03/2024
-- Description:  This stored procedure is used to get category-wise student count report
-- =============================================
CREATE PROCEDURE uspCategoryWiseStudentCountReportSelect
(
    @AcademicYearId SMALLINT,
    @classIds [SingleIdType] READONLY
)
AS 
BEGIN 
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    DECLARE @GradeId INT, @DivisionId INT;

    DECLARE @GradeDivision TABLE
    (
        GradeId INT,
        DivisionId INT
    );

    INSERT INTO @GradeDivision (GradeId, DivisionId)
    SELECT 
        sgdm.GradeId,
        sgdm.DivisionId
    FROM  
        dbo.SchoolGradeDivisionMatrix sgdm
        INNER JOIN dbo.Grade g ON sgdm.GradeId = g.GradeId
        INNER JOIN dbo.Division d ON sgdm.DivisionId = d.DivisionId
    WHERE 
        sgdm.IsDeleted <> 1 
        AND sgdm.SchoolGradeDivisionMatrixId IN (SELECT Id FROM @classIds)
        AND sgdm.AcademicYearId = @AcademicYearId;

    BEGIN TRY 
        -- CTE to calculate category-wise student counts
        WITH CategoryCounts AS (
            SELECT 
                m.AcademicYearId,
                CONCAT(g.GradeName, ' - ', d.DivisionName) AS Class,
                s.Category AS CategoryName,
                COUNT(*) AS CategoryCount
            FROM 
                Student s 
                INNER JOIN StudentGradeDivisionMapping m ON s.StudentId = m.StudentId AND m.AcademicYearId = @AcademicYearId
                INNER JOIN Grade g ON m.GradeId = g.GradeId
                INNER JOIN Division d ON m.DivisionId = d.DivisionId
            WHERE
                s.IsDeleted <> 1
                AND s.IsArchive <> 1
                AND m.GradeId IN (SELECT GradeId FROM @GradeDivision)
                AND m.DivisionId IN (SELECT DivisionId FROM @GradeDivision)
            GROUP BY 
                m.AcademicYearId,
                CONCAT(g.GradeName, ' - ', d.DivisionName),
                s.Category
        )
        -- Main query to fetch category-wise counts along with total counts
        SELECT 
            cc.AcademicYearId,
            cc.Class,
            CONCAT(UPPER(LEFT(cc.CategoryName, 1)), LOWER(SUBSTRING(cc.CategoryName, 2, LEN(cc.CategoryName) - 1))) AS CategoryName,
            COALESCE(cc.CategoryCount, 0) AS CategoryCount,
            TotalCounts.TotalCount
        FROM 
            CategoryCounts cc
            JOIN (
                -- Subquery to get total student count per class
                SELECT 
                    m.AcademicYearId,
                    CONCAT(g.GradeName, ' - ', d.DivisionName) AS Class,
                    COUNT(s.StudentId) AS TotalCount
                FROM 
                    Student s 
                    INNER JOIN StudentGradeDivisionMapping m ON s.StudentId = m.StudentId AND m.AcademicYearId = @AcademicYearId
                    INNER JOIN Grade g ON m.GradeId = g.GradeId
                    INNER JOIN Division d ON m.DivisionId = d.DivisionId
                WHERE
                    s.IsDeleted <> 1
                    AND s.IsArchive <> 1
                    AND m.GradeId IN (SELECT GradeId FROM @GradeDivision)
                    AND m.DivisionId IN (SELECT DivisionId FROM @GradeDivision)
                GROUP BY 
                    m.AcademicYearId,
                    CONCAT(g.GradeName, ' - ', d.DivisionName)
            ) AS TotalCounts ON cc.AcademicYearId = TotalCounts.AcademicYearId AND cc.Class = TotalCounts.Class
        ORDER BY 
            cc.AcademicYearId ASC,
            LEN(cc.Class) ASC, 
            cc.Class ASC,
            cc.CategoryName ASC;
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
