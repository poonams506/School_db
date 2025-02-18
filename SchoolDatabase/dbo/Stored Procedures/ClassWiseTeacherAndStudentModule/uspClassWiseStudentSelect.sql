-- =============================================
-- Author: Poonam Bhalke
-- Create date: 09/04/2024
-- Description: This stored procedure is used to get all Student info
-- =============================================

CREATE PROCEDURE uspClassWiseStudentSelect 
(
    @AcademicYearId SMALLINT ,
    @ClassTeacherId BIGINT
)
AS
BEGIN
    BEGIN TRY
        SELECT 
            tgd.AcademicYearId,
            s.StudentId,
			tgd.TeacherId AS ClassTeacherId,
            CONCAT(s.FirstName, ' ', s.MiddleName, ' ', s.LastName) AS FullName,
            CONCAT(g.GradeName, ' - ', d.DivisionName) AS ClassName
        FROM
            dbo.Student s
        INNER JOIN
            dbo.StudentGradeDivisionMapping sm ON s.StudentId = sm.StudentId
        INNER JOIN
            dbo.Grade g ON sm.GradeId = g.GradeId
        INNER JOIN
            dbo.Division d ON sm.DivisionId = d.DivisionId
        INNER JOIN
            dbo.TeacherGradeDivisionMapping tgd ON sm.GradeId = tgd.GradeId 
                                              AND sm.DivisionId = tgd.DivisionId 
                                              AND sm.AcademicYearId = tgd.AcademicYearId
        WHERE
            sm.AcademicYearId = @AcademicYearId
            AND tgd.TeacherId = @ClassTeacherId
            AND s.IsDeleted <>1 and s.IsArchive <> 1 and sm.AcademicYearId = @AcademicYearId
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
