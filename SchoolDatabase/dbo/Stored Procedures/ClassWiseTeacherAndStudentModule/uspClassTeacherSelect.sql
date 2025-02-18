-- =============================================
-- Author: Poonam Bhalke
-- Create date: 09/04/2024
-- Description: This stored procedure is used to get all ClassTeacher info
-- =============================================

CREATE PROCEDURE [dbo].[uspClassTeacherSelect ] 
(
    @AcademicYearId SMALLINT
)
AS
BEGIN
    BEGIN TRY
        SELECT 
            tm.AcademicYearId,
            t.TeacherId AS 'Id',
            CONCAT(CONCAT(g.GradeName, ' - ', d.DivisionName), '  : ', CONCAT(t.FirstName, ' ', t.MiddleName, ' ', t.LastName)) AS 'ClassTeacherName'
        FROM 
            Teacher t
            INNER JOIN TeacherGradeDivisionMapping tm ON t.TeacherId = tm.TeacherId
            INNER JOIN Grade g ON tm.GradeId = g.GradeId
            INNER JOIN dbo.Division d ON tm.DivisionId = d.DivisionId
        WHERE 
            tm.AcademicYearId = @AcademicYearId and tm.IsDeleted<>1
            AND  t.IsDeleted <> 1
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
    END CATCH 
END
