--===============================================
-- Author:    Prerana Aher
-- Create date: 13/09/2024
-- Description:  This stored procedure is used upsert Student Attendance By Month
-- =============================================
CREATE PROCEDURE [dbo].[uspStudentAttandanceByMonthUpsert]
    @AcademicYearId SMALLINT,
    @GradeId SMALLINT,
    @DivisionId SMALLINT,
    @Year INT,
    @MonthId INT, 
    @UserId INT,
    @AttendanceDataDetails dbo.[AttendanceByMonthType] READONLY
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StartDate DATE = DATEFROMPARTS(@Year, @MonthId, 1);
    DECLARE @EndDate DATE = EOMONTH(@StartDate);
    DECLARE @CurrentDateTime DATETIME = GETDATE();

    BEGIN TRY
        MERGE INTO StudentAttendance AS target
        USING @AttendanceDataDetails AS source
        ON target.StudentId = source.StudentId 
           AND target.GradeId = @GradeId
           AND target.DivisionId = @DivisionId
           AND CAST(target.AttendanceDateTime AS DATE) = CAST(source.AttendanceDateTime AS DATE)
        WHEN MATCHED THEN 
            UPDATE SET
                target.StatusId = source.StatusId, 
                target.ModifiedBy = @UserId,
                target.ModifiedDate = @CurrentDateTime
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (StudentId, AttendanceDateTime, StatusId, Reason, AcademicYearId, GradeId, DivisionId, CreatedBy, CreatedDate)
            VALUES (source.StudentId, 
                    CAST(source.AttendanceDateTime AS DATE),
                    source.StatusId, 
                    '', 
                    @AcademicYearId, 
                    @GradeId, 
                    @DivisionId, 
                    @UserId, 
                    @CurrentDateTime);
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