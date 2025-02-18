-- =============================================
-- Author:         POONAM BHALKE
-- Create date:    01/07/2024
-- Description:    This stored procedure is used to get the student gender list report.
-- =============================================
CREATE PROCEDURE [dbo].[uspStudentGenderListReportSelect] 
(
    @AcademicYearId SMALLINT,
   -- @Gender NVARCHAR(5),
    @classIds [SingleIdType] READONLY
)
AS 
BEGIN 
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    -- Declare table variables to store the GradeId and DivisionId values
    DECLARE @GradeDivision TABLE
    (
        GradeId INT,
        DivisionId INT
    );

    -- Insert GradeId and DivisionId values for each ClassId into the table variable
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
        -- Select the required data using the GradeId and DivisionId values from the table variable
        SELECT 
            CONCAT(g.GradeName, ' - ', d.DivisionName) AS [Class],
            SUM(CASE WHEN s.Gender = 'M' THEN 1 ELSE 0 END) AS [Boys],
            SUM(CASE WHEN s.Gender = 'F' THEN 1 ELSE 0 END) AS [Girls],
            CONCAT(s.FirstName, ' ', s.MiddleName, ' ', s.LastName) AS [StudentName],
            s.Gender
        FROM 
            Student s
            INNER JOIN StudentGradeDivisionMapping m ON s.StudentId = m.StudentId
            INNER JOIN Grade g ON m.GradeId = g.GradeId
            INNER JOIN Division d ON m.DivisionId = d.DivisionId
            INNER JOIN @GradeDivision gd ON m.GradeId = gd.GradeId AND m.DivisionId = gd.DivisionId
        WHERE
            m.AcademicYearId = @AcademicYearId
            AND m.IsDeleted <> 1
            AND g.IsDeleted <> 1
            AND d.IsDeleted <> 1
            AND s.IsDeleted <> 1
            AND s.IsArchive <> 1
        GROUP BY 
            CONCAT(g.GradeName, ' - ', d.DivisionName),
            s.FirstName, s.MiddleName, s.LastName, s.Gender
        ORDER BY 
            Class ASC, 
            StudentName
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
