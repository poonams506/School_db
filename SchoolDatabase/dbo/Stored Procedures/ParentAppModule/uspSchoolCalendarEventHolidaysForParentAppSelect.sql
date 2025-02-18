 -- =============================================
    -- Author: Poonam Bhalke
    -- Create date: 04/06/2024
    -- Description: This stored procedure is used to get for parent app calender data
    -- =============================================
CREATE  PROC [dbo].[uspSchoolCalendarEventHolidaysForParentAppSelect] 
(@AcademicYearId INT, @ClassId INT)
AS 
BEGIN 
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;
    
    DECLARE @GradeId INT;
    DECLARE @DivisionId INT;

    SELECT 
        @GradeId = sgdm.GradeId,
        @DivisionId = sgdm.DivisionId
    FROM  
        dbo.SchoolGradeDivisionMatrix sgdm
        JOIN dbo.Grade g ON sgdm.GradeId = g.GradeId
        JOIN dbo.Division d ON sgdm.DivisionId = d.DivisionId
    WHERE 
        sgdm.IsDeleted <> 1 
        AND sgdm.SchoolGradeDivisionMatrixId = @ClassId 
        AND sgdm.AcademicYearId = @AcademicYearId;

    BEGIN TRY 
        -- Select School Events
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
            NULL AS WeeklyOffDate,
            DisplayTime = se.StartTime,
            IsTimed = CASE WHEN se.StartTime IS NOT NULL THEN 1 ELSE 0 END
        FROM
            dbo.SchoolEvent se
            JOIN dbo.SchoolEventMapping secm ON se.SchoolEventId = secm.SchoolEventId
        WHERE
            se.IsPublished = 1
            AND se.IsDeleted <> 1
            AND se.AcademicYearId = @AcademicYearId
            AND secm.GradeId = @GradeId
            AND secm.DivisionId = @DivisionId

        UNION

        -- Select School Holidays
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
            NULL AS WeeklyOffDate,
             DisplayTime = NULL,
            IsTimed = 0
        FROM
            dbo.SchoolHolidays sh
        WHERE
            sh.IsDeleted <> 1
            AND sh.AcademicYearId = @AcademicYearId
          

        UNION

        -- Select School Vacations
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
            NULL AS WeeklyOffDate,
             DisplayTime = NULL,
            IsTimed = 0
        FROM 
            dbo.SchoolVacation sv
        WHERE 
            sv.AcademicYearId = @AcademicYearId
            AND ISNULL(sv.IsDeleted, 0) <> 1
  UNION 

        SELECT 
             NULL AS Id,
            'WeeklyOff' AS EventType,
			wt.AcademicYearId,
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
            wt.Holidays AS WeeklyOffDate,
             DisplayTime = CAST(wt.Holidays AS TIME),
            IsTimed = CASE WHEN wt.Holidays IS NOT NULL THEN 1 ELSE 0 END
        FROM 
            dbo.udfGetWeeklyOff(@AcademicYearId) AS wt
                WHERE
            
             wt.AcademicYearId = @AcademicYearId
        
        ORDER BY 
            IsTimed DESC,          
            DisplayTime ASC,       
            EventType ASC;         
        SELECT 
            se.SchoolEventId,
            sed.SchoolEventDetailsId,
            sed.FileName
        FROM 
            dbo.SchoolEvent se 
            JOIN dbo.SchoolEventDetails sed ON se.SchoolEventId = sed.SchoolEventId
        WHERE 
            se.AcademicYearId = @AcademicYearId
            AND se.IsPublished = 1 
            AND se.IsDeleted <>1
            AND sed.IsDeleted<>1

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

