CREATE PROC dbo.uspHolidayTeacherAttendanceSelect
(@AcademicYearId INT)
AS 
BEGIN 
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;
    
    BEGIN TRY 

	 SELECT
           wo.WeeklyOffId,
		   wo.DayNo
        FROM 
            dbo.WeeklyOff AS wo
        WHERE
            wo.AcademicYearId = @AcademicYearId AND
            ISNULL(wo.IsDeleted, 0) <> 1;

        SELECT
            sh.SchoolHolidayId,
            sh.DayNo,
            sh.CalendarDate,
            sh.HolidayReason
        FROM 
            dbo.SchoolHolidays AS sh
        WHERE
            sh.AcademicYearId = @AcademicYearId AND
            ISNULL(sh.IsDeleted, 0) <> 1;
            	
        SELECT
            sv.SchoolVacationId,
            sv.StartDate,
            sv.EndDate,
           sv.VacationName
            
        FROM 
            dbo.SchoolVacation AS sv
        WHERE
            sv.AcademicYearId = @AcademicYearId 
            AND  ISNULL(sv.IsDeleted, 0) <> 1;

    END TRY 
    
    BEGIN CATCH 
        DECLARE @ErrorMessage VARCHAR(5000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        DECLARE @ErrorNumber INT = ERROR_NUMBER();
        DECLARE @ErrorLine INT = ERROR_LINE();
        DECLARE @ErrorProcedure NVARCHAR(1000) = ERROR_PROCEDURE();
        EXEC dbo.uspExceptionLogInsert @ErrorLine,
            @ErrorMessage,
            @ErrorNumber,
            @ErrorProcedure,
            @ErrorSeverity,
            @ErrorState;
    END CATCH 
END
GO
