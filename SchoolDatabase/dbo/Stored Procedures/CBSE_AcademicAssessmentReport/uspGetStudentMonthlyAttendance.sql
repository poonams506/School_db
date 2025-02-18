-- =============================================
-- Author:    Prerana Aher
-- Create date: 19/11/2024               
-- Description:  This stored procedure is used to get student Monthly Attendance
-- =============================================
CREATE PROCEDURE [dbo].[uspGetStudentMonthlyAttendance]
    @StudentId INT,
    @AcademicYearId INT
AS
BEGIN TRY
    DECLARE @StartDate DATETIME = (SELECT AcademicYearStartMonth 
                                   FROM SchoolSetting 
                                   WHERE AcademicYearId = @AcademicYearId AND IsDeleted <> 1);
    DECLARE @EndDate DATETIME = DATEADD(MONTH, 11, @StartDate);

    WITH WorkingDaysCTE AS (
        SELECT 
            FORMAT(WorkingDays, 'MMM') AS MonthName, 
            MONTH(WorkingDays) AS MonthNumber,
            COUNT(*) AS TotalWorkingDays
        FROM 
            dbo.udfGetSchoolWorkingDaysUptoCurrentDate(@AcademicYearId)
        WHERE 
            WorkingDays BETWEEN @StartDate AND @EndDate
        GROUP BY 
            FORMAT(WorkingDays, 'MMM'), MONTH(WorkingDays)
    ),
    PresentDaysCTE AS (
        SELECT 
            FORMAT(A.AttendanceDateTime, 'MMM') AS MonthName, 
            MONTH(A.AttendanceDateTime) AS MonthNumber,
            COUNT(*) AS PresentDays
        FROM 
            StudentAttendance A
        WHERE 
            A.StudentID = @StudentId
            AND A.StatusId = 1
            AND A.AttendanceDateTime BETWEEN @StartDate AND @EndDate
            AND A.AcademicYearId=@AcademicYearId
            AND A.IsDeleted<>1
        GROUP BY 
            FORMAT(A.AttendanceDateTime, 'MMM'), MONTH(A.AttendanceDateTime)
    )
    SELECT 
        WD.MonthName,
        WD.TotalWorkingDays,
        ISNULL(PD.PresentDays, 0) AS PresentDays
    FROM 
        WorkingDaysCTE WD
		LEFT JOIN PresentDaysCTE PD ON WD.MonthNumber = PD.MonthNumber
    ORDER BY 
        (WD.MonthNumber + 12 - MONTH(@StartDate)) % 12 

    OPTION (MAXRECURSION 0); 

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
END CATCH;
