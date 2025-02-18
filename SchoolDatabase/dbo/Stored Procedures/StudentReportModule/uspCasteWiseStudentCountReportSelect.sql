-- =============================================
-- Author:   POONAM BHALKE
-- Create date: 01/07/2024
-- Description:  This stored procedure is used to get caste-wise student count report
-- =============================================
CREATE PROCEDURE [dbo].[uspCasteWiseStudentCountReportSelect]
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
        -- CTE to calculate caste-wise student counts
        WITH CasteCounts AS (
            SELECT 
                m.AcademicYearId,
                CONCAT(g.GradeName, ' - ', d.DivisionName) AS Class,
                s.Cast AS CasteName,
                COUNT(*) AS CasteCount
            FROM 
                Student s
                INNER JOIN StudentGradeDivisionMapping m ON s.StudentId = m.StudentId
                INNER JOIN Grade g ON m.GradeId = g.GradeId
                INNER JOIN Division d ON m.DivisionId = d.DivisionId
                INNER JOIN @GradeDivision gd ON m.GradeId = gd.GradeId AND m.DivisionId = gd.DivisionId
            WHERE
                s.IsDeleted <> 1
                AND s.IsArchive <> 1
            GROUP BY 
                m.AcademicYearId,
                CONCAT(g.GradeName, ' - ', d.DivisionName),
                s.Cast
        )
        -- Main query to fetch caste-wise counts along with total counts
        SELECT 
            cc.AcademicYearId,
            cc.Class,
            cc.CasteName,
			CONCAT(UPPER(LEFT(cc.CasteName, 1)), LOWER(SUBSTRING(cc.CasteName, 2, LEN(cc.CasteName) - 1))) AS FormattedCasteName,
            COALESCE(cc.CasteCount, 0) AS CasteCount,
            tc.TotalCount
        FROM 
            CasteCounts cc
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
                GROUP BY 
                    m.AcademicYearId,
                    CONCAT(g.GradeName, ' - ', d.DivisionName)
            ) AS tc ON cc.AcademicYearId = tc.AcademicYearId AND cc.Class = tc.Class
        GROUP BY 
            cc.AcademicYearId, 
            cc.Class, 
            cc.CasteName, 
            cc.CasteCount, 
            tc.TotalCount
        ORDER BY 
            cc.AcademicYearId ASC,
            LEN(cc.Class) ASC, 
            cc.Class ASC,
            cc.CasteName ASC;
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
