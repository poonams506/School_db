-- =============================================
-- Author: Saurabh Walunj
-- Create date: 15/05/2024
-- Description: This stored procedure is used to get Class Attendance Report for parent app dashboard data
-- =============================================
CREATE PROCEDURE uspAttendanceStatusParentAppSelect
    @AcademicYearId INT,  
    @StudentId INT
AS 
BEGIN 
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    DECLARE @CurrentDate DATE = CAST(GETDATE() AS DATE);

    BEGIN TRY 
        SELECT
            @AcademicYearId AS AcademicYearId,
            @StudentId AS StudentId,
            CASE
                WHEN sa.AttendanceDateTime IS NULL THEN 'Attendance Pending'
                WHEN sa.StatusId = 1 THEN 'Present'
                WHEN sa.StatusId = 3 THEN 'Absent'
                ELSE 'Half Day Present'
            END AS 'Status'
        FROM 
            (SELECT DISTINCT
                @AcademicYearId AS AcademicYearId,
                @StudentId AS StudentId
            ) s
        LEFT JOIN 
            StudentAttendance sa 
            ON s.StudentId = sa.StudentId 
            AND sa.AcademicYearId = @AcademicYearId 
            AND CAST(sa.AttendanceDateTime AS DATE) = @CurrentDate
            AND sa.IsDeleted <> 1;

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

