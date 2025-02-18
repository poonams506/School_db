-- =============================================
-- Author: Poonam Bhalke
-- Create date: 08/04/2024
-- Description: This stored procedure is used to get Survey detail by Select
-- =============================================
CREATE PROCEDURE uspSurveySelect
(
    @SurveyId BIGINT
)
AS 
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    BEGIN TRY 
        DECLARE @AcademicYearId INT;

        SELECT @AcademicYearId = s.AcademicYearId
        FROM dbo.Survey AS s
        WHERE
            s.SurveyId = @SurveyId 
            AND s.IsDeleted <> 1;

        SELECT 
            s.SurveyId,
            s.IsImportant,
            s.SurveyToType,
            s.Title AS SurveyTitle,
            s.[Description] AS SurveyDescription,
            s.StartDate,
            s.EndDate,
            s.IsPublished
        FROM dbo.Survey AS s
        WHERE 
            s.SurveyId = @SurveyId 
            AND s.IsDeleted <> 1;

        SELECT 
            sd.SurveyId,
            sd.FileName,
            sd.FileType
        FROM dbo.SurveyDetails AS sd
        WHERE 
            sd.SurveyId = @SurveyId 
            AND sd.IsDeleted <> 1 
            AND sd.FileType = 1;

        SELECT 
            sqd.SurveyId,
            sqd.SurveyQuestions
        FROM dbo.SurveyQuestionDetails AS sqd
        WHERE 
            sqd.SurveyId = @SurveyId
            AND sqd.IsDeleted <> 1;

        SELECT 
            sm.SurveyId,
            sm.StudentId,
            sgdm.SchoolGradeDivisionMatrixId AS ClassId,
            sm.TeacherId,
            sm.ClerkId,
            sm.CabDriverId,
            sm.ClassTeacherId
        FROM dbo.SurveyMapping AS sm
        LEFT JOIN dbo.SchoolGradeDivisionMatrix sgdm ON sm.GradeId = sgdm.GradeId AND sm.DivisionId = sgdm.DivisionId AND sgdm.AcademicYearId = @AcademicYearId
        WHERE
            sm.SurveyId = @SurveyId
            AND (sgdm.IsDeleted <> 1 OR sgdm.SchoolGradeDivisionMatrixId IS NULL);
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
    END CATCH;
END;
