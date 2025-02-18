-- =============================================
-- Author:        Tejas Rahane
-- Create date:   18/11/2024
-- Description:   This stored procedure retrieves subject index number details
-- =============================================
CREATE PROC [dbo].[uspSubjectIndexNumberDetailsSelect] 
(
    @GradeId INT,
    @DivisionId INT,
    @AcademicYearId INT
)
AS 
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    BEGIN TRY
        
        SELECT DISTINCT
            s.AcademicYearId,
            s.GradeId,
            g.GradeName,
            s.DivisionId,
            d.DivisionName
        FROM 
            dbo.SubjectMapping AS s
            INNER JOIN SubjectMaster AS st ON s.SubjectMasterId = st.SubjectMasterId
            INNER JOIN Grade g ON s.GradeId = g.GradeId
            INNER JOIN Division d ON s.DivisionId = d.DivisionId
        WHERE 
            g.GradeId = @GradeId
            AND d.DivisionId = @DivisionId
            AND s.AcademicYearId = @AcademicYearId
            AND s.IsDeleted <> 1
            AND g.IsDeleted <> 1
            AND d.IsDeleted <> 1;

        
        SELECT 
            s.SubjectMappingId,
            s.IndexNumber,
            s.SubjectMasterId,
            st.SubjectName
        FROM 
            dbo.SubjectMapping AS s
            INNER JOIN SubjectMaster AS st ON s.SubjectMasterId = st.SubjectMasterId
            INNER JOIN Grade g ON s.GradeId = g.GradeId
            INNER JOIN Division d ON s.DivisionId = d.DivisionId
        WHERE 
            g.GradeId = @GradeId
            AND d.DivisionId = @DivisionId
            AND s.AcademicYearId = @AcademicYearId
            AND s.IsDeleted <> 1
            AND g.IsDeleted <> 1
            AND d.IsDeleted <> 1;
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