-- =============================================
-- Author:    Tejas Rahane
-- Create date: 25/11/2024
-- Description:  This stored procedure is used to clone subject mapping
-- =============================================
CREATE PROCEDURE [dbo].[uspSubjectMappingClone]
(
    @AcademicYearId INT, 
    @FromClassId INT,
    @ToClassId dbo.[SingleIdType] READONLY,
    @UserId INT
)
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @FromGradeId SMALLINT;
        DECLARE @FromDivisionId SMALLINT;

        
        SELECT 
            @FromGradeId = sgdm.GradeId,
            @FromDivisionId = sgdm.DivisionId
        FROM dbo.SchoolGradeDivisionMatrix sgdm
        JOIN dbo.Grade g ON sgdm.GradeId = g.GradeId
        JOIN dbo.Division d ON sgdm.DivisionId = d.DivisionId
        WHERE sgdm.IsDeleted <> 1 
          AND sgdm.SchoolGradeDivisionMatrixId = @FromClassId 
          AND sgdm.AcademicYearId = @AcademicYearId;

        DECLARE @CurrentDateTime DATETIME = GETDATE();

        
        DELETE FROM dbo.SubjectMapping
        WHERE AcademicYearId = @AcademicYearId
          AND DivisionId IN (SELECT DivisionId FROM dbo.SchoolGradeDivisionMatrix WHERE SchoolGradeDivisionMatrixId IN (SELECT Id FROM @ToClassId))
          AND GradeId IN (SELECT GradeId FROM dbo.SchoolGradeDivisionMatrix WHERE SchoolGradeDivisionMatrixId IN (SELECT Id FROM @ToClassId))
          AND IsDeleted <> 1;

        
        INSERT INTO dbo.SubjectMapping(AcademicYearId, GradeId, DivisionId, IndexNumber, SubjectMasterId, CreatedBy, CreatedDate)
        SELECT 
            @AcademicYearId, 
            sgdm.GradeId, 
            sgdm.DivisionId, 
            f.IndexNumber, 
            f.SubjectMasterId, 
            @UserId, 
            @CurrentDateTime
        FROM dbo.SubjectMapping f
        CROSS JOIN dbo.SchoolGradeDivisionMatrix sgdm
        JOIN @ToClassId d ON sgdm.SchoolGradeDivisionMatrixId = d.Id
        WHERE f.GradeId = @FromGradeId
          AND f.DivisionId = @FromDivisionId
          AND f.AcademicYearId = @AcademicYearId
          AND f.IsDeleted <> 1;

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
END
GO