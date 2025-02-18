-- =============================================
-- Author:    Poonam Bhalke
-- Create date: 28/08/2023
-- Description: This stored procedure is used to get Homework info detail by Select
-- =============================================
CREATE PROC [dbo].[uspHomeWorkSelect] 
(
    @HomeWorkId BIGINT
)
AS 
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;
    
    BEGIN TRY 
        SELECT 
            h.HomeWorkId,
            sgdm.SchoolGradeDivisionMatrixId AS 'ClassId',
            h.SubjectId,
			sm.SubjectName,
            h.Title AS HomeworkTitle,
            h.[Description] AS HomeworkDescription,
            h.StartDate,
            h.EndDate,
            h.IsPublished
        FROM 
            dbo.HomeWork AS h
            INNER JOIN dbo.SchoolGradeDivisionMatrix sgdm ON h.GradeId = sgdm.GradeId AND h.DivisionId = sgdm.DivisionId AND h.AcademicYearId = sgdm.AcademicYearId
            INNER JOIN dbo.Grade g ON h.GradeId = g.GradeId
            INNER JOIN dbo.Division d ON h.DivisionId = d.DivisionId
			INNER JOIN dbo.SubjectMaster sm ON h.SubjectId= sm.SubjectMasterId
        WHERE
            h.HomeWorkId = @HomeWorkId AND
            h.IsDeleted <> 1 AND
            sgdm.IsDeleted <> 1

        SELECT 
            hw.HomeWorkId,
            hw.FileName,
            hw.FileType
        FROM
            dbo.HomeWorkDetails AS hw
        WHERE
            hw.HomeWorkId = @HomeWorkId AND
            hw.IsDeleted <> 1 AND 
            hw.FileType = 1;

        SELECT 
            hmd.HomeWorkId,
            hmd.ContentUrl
        FROM
            dbo.HomeworkMediaDetail AS hmd
        WHERE
            hmd.HomeWorkId = @HomeWorkId 
            AND hmd.IsDeleted <> 1;
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
    END CATCH
END


