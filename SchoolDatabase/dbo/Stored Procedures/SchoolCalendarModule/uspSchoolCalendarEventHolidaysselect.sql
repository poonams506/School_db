-- =============================================
-- Author:   Prathamesh Ghule
-- Create date: 05/03/2024
-- Description:  This stored procedure is used to get school event and holiday   data
-- =============================================
CREATE PROCEDURE uspSchoolCalendarEventHolidaysselect (@AcademicYearId INT) AS BEGIN 
SET 
  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET 
  NOCOUNT ON;
BEGIN TRY 
   
    SELECT 
            'Event' AS EventType,
            se.AcademicYearId,
            se.EventTitle,
            se.EventCoordinator,
            se.StartDate,
            se.EndDate,
            se.StartTime,
            se.EndTime,
            se.IsPublished,
            se.IsCompulsory,
            NULL AS VacationName,
            NULL AS VacationStartDate,
            NULL AS VacationEndDate,
            NULL AS HolidayReason,
            NULL AS CalendarDate,
            NULL AS WeeklyOffName,
            NULL AS WeeklyOffDate
        FROM
            [dbo].[SchoolEvent] se
        WHERE
            se.IsPublished = 1
            AND se.IsDeleted <> 1
            AND se.AcademicYearId = @AcademicYearId

        UNION

        SELECT 
            'Holiday' AS EventType,
            sh.AcademicYearId,
            NULL AS EventTitle,
            NULL AS EventCoordinator,
            NULL AS StartDate,
            NULL AS EndDate,
            NULL AS StartTime,
            NULL AS EndTime,
            NULL AS IsPublished,
            NULL AS IsCompulsory,
            NULL AS VacationName,
            NULL AS VacationStartDate,
            NULL AS VacationEndDate,
            sh.HolidayReason,
            sh.CalendarDate,
            NULL AS WeeklyOffName,
            NULL AS WeeklyOffDate
        FROM
            [dbo].[SchoolHolidays] sh
        WHERE
            sh.IsDeleted <> 1
            AND sh.AcademicYearId = @AcademicYearId

        UNION 

        SELECT 
            'Vacation' AS EventType,
            sv.AcademicYearId,
            NULL AS EventTitle,
            NULL AS EventCoordinator,
            NULL AS StartDate,
            NULL AS EndDate,
            NULL AS StartTime,
            NULL AS EndTime,
            NULL AS IsPublished,
            NULL AS IsCompulsory,
            sv.VacationName,
            sv.StartDate,
            sv.EndDate,
            NULL AS HolidayReason,
            NULL AS CalendarDate,
            NULL AS WeeklyOffName,
            NULL AS WeeklyOffDate
        FROM
            [dbo].[SchoolVacation] sv
        WHERE
            sv.IsDeleted <> 1
            AND sv.AcademicYearId = @AcademicYearId

        UNION 

        SELECT 
            'WeeklyOff' AS EventType,
            NULL AS AcademicYearId,
            NULL AS EventTitle,
            NULL AS EventCoordinator,
            NULL AS StartDate,
            NULL AS EndDate,
            NULL AS StartTime,
            NULL AS EndTime,
            NULL AS IsPublished,
            NULL AS IsCompulsory,
            NULL AS VacationName,
            NULL AS VacationStartDate,
            NULL AS VacationEndDate,
            NULL AS HolidayReason,
            NULL AS CalendarDate,
            wt.WeeklyOffName,
            wt.Holidays AS WeeklyOffDate
        FROM 
            dbo.udfGetWeeklyOff(@AcademicYearId) AS wt
             WHERE
            
             wt.AcademicYearId = @AcademicYearId;
  
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


