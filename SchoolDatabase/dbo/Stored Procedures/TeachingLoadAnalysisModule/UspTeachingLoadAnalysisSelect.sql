-- =============================================
-- Author: Poonam Bhalke
-- Create date: 02/04/2024
-- Description:  This stored procedure is used to get Teacher Load Analysis info
-- =============================================

CREATE PROCEDURE UspTeachingLoadAnalysisSelect
(
    @AcademicYearId INT
)
AS
BEGIN
    BEGIN TRY
    with cteTeacher AS (
SELECT DISTINCT
    t.TeacherId,
    ta.AcademicYearId,
    ta.LecturePerWeek,
    t.FirstName + ' ' + t.MiddleName + ' ' + t.LastName AS 'FullName'
FROM 
Teacher AS t 
	INNER JOIN TeacherAcademicDetail ta 
	on ta.TeacherId = t.TeacherId AND t.IsDeleted <> 1
	AND ta.AcademicYearId = @AcademicYearId
    AND ta.LecturePerWeek > 0
	)

SELECT DISTINCT
temp.TeacherId,
temp.AcademicYearId,
temp.LecturePerWeek,
temp.FullName,
    COUNT(c.ClassTimeTableId) AS 'ClassTimeTableCount',
    FORMAT(((COUNT(c.ClassTimeTableId) * 1.0 / temp.LecturePerWeek) * 100),'0.00') AS 'TeacherPercentage'
FROM 
    ClassTimeTable ct
INNER JOIN 
    ClassTimeTableColumnDetail c ON c.ClassTimeTableId = ct.ClassTimeTableId AND ct.isActive = 1 AND ct.IsDeleted <> 1 AND c.IsDeleted <> 1
	AND ct.AcademicYearId = @AcademicYearId
RIGHT JOIN cteTeacher temp
on temp.TeacherId = c.TeacherId
GROUP BY 
    temp.TeacherId,temp.AcademicYearId,temp.FullName, temp.LecturePerWeek;


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
