-- =============================================
-- Author:    Prerana Aher
-- Create date: 13/09/2024
-- Description:  This stored procedure is used to get student Attendance By month info detail by Select 
-- =============================================
CREATE PROCEDURE [dbo].[uspGetStudentAttendanceByMonthSelect]
(
    @AcademicYearId SMALLINT,
    @GradeId SMALLINT,
    @DivisionId SMALLINT,
    @MonthId INT,
    @YearId INT
)
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    BEGIN TRY 
        DECLARE @StartDate DATE = DATEFROMPARTS(@YearId, @MonthId, 1);
        DECLARE @EndDate DATE = EOMONTH(@StartDate);

		 SELECT 
            s.StudentId,
			sgdm.RollNumber,
            CONCAT(s.FirstName, ' ', s.MiddleName, ' ', s.LastName) AS 'StudentName'
        FROM Student s
        INNER JOIN StudentGradeDivisionMapping sgdm ON s.StudentId = sgdm.StudentId   
        WHERE sgdm.AcademicYearId = @AcademicYearId
          AND sgdm.GradeId = @GradeId
          AND sgdm.DivisionId = @DivisionId
          AND s.IsDeleted <> 1
          AND s.IsArchive <> 1
        ORDER BY 
            StudentName; -- Ensure alphabetical ordering of StudentName

        -- Main Query
        WITH Calendar AS (
            SELECT @StartDate AS CalendarDate
            UNION ALL
            SELECT DATEADD(DAY, 1, CalendarDate)
            FROM Calendar
            WHERE CalendarDate < @EndDate
        ),
        StudentAttendance AS (
            SELECT 
                s.StudentId,
				sgdm.RollNumber,
                CONCAT(s.FirstName, ' ', s.LastName) AS StudentName,
                ISNULL(sa.StatusId, 0) AS StatusId,
                c.CalendarDate AS AttendanceDateTime,
                CONCAT(DATENAME(MONTH, @StartDate), ' ', @YearId) AS Month,  -- Updated to required format
                CONCAT(g.GradeName, '-', d.DivisionName) AS ClassName  
            FROM dbo.Student AS s
            INNER JOIN dbo.StudentGradeDivisionMapping AS sgdm ON s.StudentId = sgdm.StudentId
            INNER JOIN dbo.Grade AS g ON sgdm.GradeId = g.GradeId
            INNER JOIN dbo.Division AS d ON sgdm.DivisionId = d.DivisionId
            CROSS JOIN Calendar AS c
            LEFT JOIN dbo.StudentAttendance AS sa ON s.StudentId = sa.StudentId  
                AND CAST(sa.AttendanceDateTime AS DATE) = c.CalendarDate 
                AND sa.AcademicYearId = @AcademicYearId
                AND sa.GradeId = @GradeId
                AND sa.DivisionId = @DivisionId
            WHERE
                sgdm.AcademicYearId = @AcademicYearId
                AND sgdm.GradeId = @GradeId
                AND sgdm.DivisionId = @DivisionId
                AND s.IsDeleted <> 1
                AND s.IsArchive <> 1
        ),
        AttendanceOrdered AS (
            SELECT 
                StudentId,
				RollNumber,
                StudentName,
                StatusId,
                AttendanceDateTime,
                Month,
                ClassName,
                ROW_NUMBER() OVER (PARTITION BY StudentId, AttendanceDateTime ORDER BY AttendanceDateTime ASC) AS SequenceNumber
            FROM 
                StudentAttendance
        )

        -- Select distinct attendance records by StatusId and AttendanceDateTime per student
        SELECT DISTINCT
            StudentId,
			RollNumber,
            StudentName,
            StatusId,
            AttendanceDateTime,
            Month,
            ClassName   
        FROM 
            AttendanceOrdered
        WHERE 
            SequenceNumber = 1  -- Ensure to pick the first record for each day
        ORDER BY 
             StudentName, StudentId, AttendanceDateTime

        OPTION (MAXRECURSION 0);  



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
END;