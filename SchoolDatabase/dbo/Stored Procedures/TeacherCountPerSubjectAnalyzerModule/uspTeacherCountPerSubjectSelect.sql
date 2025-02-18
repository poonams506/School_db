-- =============================================
-- Author: Poonam Bhalke
-- Create date: 13/03/2024
-- Description:  This stored procedure is used to get Teacher Count against Subject info
-- =============================================

CREATE PROCEDURE uspTeacherCountPerSubjectSelect
(
    @AcademicYearId INT
)
AS
BEGIN
    BEGIN TRY
       SELECT 
            tsm.AcademicYearId,
            sm.SubjectName,
            COUNT(tsm.TeacherId) AS 'TeacherCount'
        FROM 
            TeacherSubjectMapping AS tsm
        RIGHT JOIN 
            SubjectMaster AS sm ON tsm.SubjectMasterId = sm.SubjectMasterId
            AND tsm.AcademicYearId = @AcademicYearId
			AND tsm.IsDeleted <> 1
        WHERE 
		    sm.IsDeleted<>1
        GROUP BY 
            tsm.AcademicYearId,
            sm.SubjectName
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

