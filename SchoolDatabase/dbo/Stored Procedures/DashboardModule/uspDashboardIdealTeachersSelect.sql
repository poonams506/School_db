-- =============================================
-- Author:    Deepak W
-- Create date: 06/03/2024
-- Description:  This stored procedure is used to get ideal teacher in specific time period
-- =============================================
CREATE PROC dbo.uspDashboardIdealTeachersSelect
@AcademicYearId INT
AS Begin 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 

  
DECLARE @DaysTable TABLE(_dayNo TINYINT NOT NULL, _dayName VARCHAR(20) NOT NULL)
INSERT INTO @DaysTable(_dayNo, _dayName) VALUES(1,'Sunday'),(2,'Monday'),
                      (3,'Tuesday'),(4,'Wednesday'),(5,'Thursday'),
                      (6,'Friday'),(7,'Saturday')
DECLARE @TodaysDayInInt tinyint;
DECLARE @TodaysDayInWord VARCHAR(20);
SET @TodaysDayInWord = DATENAME(WEEKDAY, GetDate());
SELECT @TodaysDayInInt = _dayNo FROM @DaysTable WHERE _dayName = @TodaysDayInWord;



SELECT DISTINCT rd.StartingHour, rd.StartingMinute, rd.EndingHour, rd.EndingMinute
FROM [dbo].[ClassTimeTable] t
INNER JOIN [dbo].[ClassTimeTableRowDetail] rd
on rd.ClassTimeTableId = t.ClassTimeTableId
INNER JOIN [dbo].[ClassTimeTableColumnDetail] cd
on t.ClassTimeTableId = cd.ClassTimeTableId and rd.ClassTimeTableRowDetailId = cd.ClassTimeTableRowDetailId
where t.IsDeleted <> 1 AND t.isActive = 1
AND cd.IsDeleted <> 1 AND cd.DayNo = @TodaysDayInInt AND rd.PeriodTypeId = 1 AND t.AcademicYearId = @AcademicYearId  and rd.IsDeleted <> 1
order by rd.StartingHour asc



SELECT rd.StartingHour, rd.StartingMinute, rd.EndingHour, rd.EndingMinute ,cd.TeacherId, t.GradeId,t.DivisionId
FROM [dbo].[ClassTimeTable] t
INNER JOIN [dbo].[ClassTimeTableRowDetail] rd
on rd.ClassTimeTableId = t.ClassTimeTableId
INNER JOIN [dbo].[ClassTimeTableColumnDetail] cd
on t.ClassTimeTableId = cd.ClassTimeTableId and rd.ClassTimeTableRowDetailId = cd.ClassTimeTableRowDetailId
where t.IsDeleted <> 1 AND t.isActive = 1
AND cd.IsDeleted <> 1 AND cd.DayNo = @TodaysDayInInt AND rd.PeriodTypeId = 1 AND t.AcademicYearId = @AcademicYearId and rd.IsDeleted <> 1
order by rd.StartingHour asc


SELECT DISTINCT t.TeacherId, CONCAT(t.FirstName, ' ', t.MiddleName, ' ', t.LastName) AS TeacherName, 
  t.MobileNumber, t.ProfileImageUrl, STUFF(( SELECT ', ' + s.SubjectName
            FROM dbo.SubjectMaster s
            LEFT JOIN dbo.TeacherSubjectMapping m ON m.SubjectMasterId = s.SubjectMasterId AND m.AcademicYearId = @AcademicYearId
            WHERE m.TeacherId = t.TeacherId AND s.IsDeleted <> 1 AND m.IsDeleted <> 1
            FOR XML PATH('')),1, 2, '' ) AS SubjectNames
FROM dbo.Teacher t
LEFT JOIN TeacherGradeDivisionMapping tm ON t.TeacherId = tm.TeacherId AND tm.AcademicYearId = @AcademicYearId
WHERE t.IsDeleted <> 1
ORDER BY TeacherName ASC;

END TRY BEGIN CATCH DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
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
@ErrorState END CATCH
END	 
