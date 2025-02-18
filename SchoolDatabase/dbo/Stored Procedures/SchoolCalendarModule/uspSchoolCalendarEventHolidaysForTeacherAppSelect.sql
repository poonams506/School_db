-- =============================================
-- Author:   Abhishek Kumar
-- Create date: 02/04/2024
-- Description:  This stored procedure is used to get school event and holiday for teacher app
-- =============================================

CREATE PROC dbo.uspSchoolCalendarEventHolidaysForTeacherAppSelect 
(@AcademicYearId int)
AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 
with cte1 as (
 SELECT 
                se.SchoolEventId AS Id,
                'Event' AS EventType,
                se.AcademicYearId,
                se.EventTitle,
                se.EventCoordinator,
                se.EventFess,
                se.StartDate,
                se.EndDate,
                se.StartTime,
                se.EndTime,
                se.IsPublished,
                se.IsCompulsory,
                se.EventDescription,
                NULL AS CalendarDate,
                NULL AS HolidayReason,
                NULL AS VacationName,
                NULL AS VacationStartDate,
                NULL AS VacationEndDate,
                NULL AS WeeklyOffName,
                NULL AS WeeklyOffDate
            FROM
                dbo.SchoolEvent se
            WHERE
                se.IsPublished = 1
                AND se.IsDeleted <> 1
                AND se.AcademicYearId = @AcademicYearId

            UNION ALL

            SELECT 
                sh.SchoolHolidayId AS Id,
                'Holiday' AS EventType,
                sh.AcademicYearId,
                NULL AS EventTitle,
                NULL AS EventCoordinator,
                NULL AS EventFess,
                NULL AS StartDate,
                NULL AS EndDate,
                NULL AS StartTime,
                NULL AS EndTime,
                NULL AS IsPublished,
                NULL AS IsCompulsory,
                NULL AS EventDescription,
                sh.CalendarDate,
                sh.HolidayReason,
                NULL AS VacationName,
                NULL AS VacationStartDate,
                NULL AS VacationEndDate,
                NULL AS WeeklyOffName,
                NULL AS WeeklyOffDate
            FROM
                dbo.SchoolHolidays sh
            WHERE
                sh.IsDeleted <> 1
                AND sh.AcademicYearId = @AcademicYearId

            UNION ALL

            SELECT 
                sv.SchoolVacationId AS Id,
                'Vacation' AS EventType,
                sv.AcademicYearId,
                NULL AS EventTitle,
                NULL AS EventCoordinator,
                NULL AS EventFess,
                NULL AS StartDate,
                NULL AS EndDate,
                NULL AS StartTime,
                NULL AS EndTime,
                NULL AS IsPublished,
                NULL AS IsCompulsory,
                NULL AS EventDescription,
                NULL AS CalendarDate,
                NULL AS HolidayReason,
                sv.VacationName,
                sv.StartDate AS VacationStartDate,
                sv.EndDate AS VacationEndDate,
                NULL AS WeeklyOffName,
                NULL AS WeeklyOffDate
            FROM 
                dbo.SchoolVacation sv
            WHERE 
                sv.AcademicYearId = @AcademicYearId
                AND ISNULL(sv.IsDeleted, 0) <> 1

            UNION ALL

            SELECT 
                NULL AS Id,
                'WeeklyOff' AS EventType,
                NULL AS AcademicYearId,
                NULL AS EventTitle,
                NULL AS EventCoordinator,
                NULL AS EventFess,
                NULL AS StartDate,
                NULL AS EndDate,
                NULL AS StartTime,
                NULL AS EndTime,
                NULL AS IsPublished,
                NULL AS IsCompulsory,
                NULL AS EventDescription,
                NULL AS CalendarDate,
                NULL AS HolidayReason,
                NULL AS VacationName,
                NULL AS VacationStartDate,
                NULL AS VacationEndDate,
                wt.WeeklyOffName,
                wt.Holidays AS WeeklyOffDate
            FROM 
                dbo.udfGetWeeklyOff(@AcademicYearId) AS wt
            WHERE
                wt.AcademicYearId = @AcademicYearId
     )

SELECT * FROM cte1 ORDER BY
CASE WHEN StartTime IS NULL THEN 9999999 ELSE -1 END, 
StartTime ASC;

SELECT 
    se.SchoolEventId,
	sed.SchoolEventDetailsId,
	sed.FileName
FROM 
	 dbo.SchoolEvent se 
     JOIN dbo.SchoolEventDetails sed ON se.SchoolEventId=sed.SchoolEventId
WHERE
     se.AcademicYearId=@AcademicYearId
	 AND se.IsPublished=1
     AND se.IsDeleted <>1
     AND sed.IsDeleted<>1


  
END TRY BEGIN CATCH DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
DECLARE @Errorseverity INT = ERROR_seVERITY();
DECLARE @ErrorState INT = ERROR_STATE();
DECLARE @ErrorNumber INT = ERROR_NUMBER();
DECLARE @ErrorLine INT = ERROR_LINE();
DECLARE @ErrorProcedure NVARCHAR(1000) = ERROR_PROCEDURE();
EXEC uspExceptionLogInsert @ErrorLine, 
@ErrorMessage, 
@ErrorNumber, 
@ErrorProcedure, 
@Errorseverity, 
@ErrorState END CATCH End


GO
