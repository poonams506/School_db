-- =============================================
-- Author: Prathamesh Ghule
-- Create date: 18/03/2024
-- Description: This stored procedure is used to get Class Meassing Attendance Report data
-- =============================================
CREATE PROCEDURE [dbo].[uspClassAttendanceMissingReportSelect] 
(
@AcademicYearId INT,
@RefId INT,
@RoleId INT
     ) 
AS 
BEGIN 
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;
	DECLARE @CurrentDateTime DATETIME = GETDATE();
    BEGIN TRY 
      IF @RoleId = 1 or @RoleId = 2 or @RoleId = 4
      BEGIN
                  SELECT DISTINCT
                dm.WorkingDays AS 'AttendanceMissingDate',
               sm.GradeId,
               g.GradeName,
               d.DivisionName,
               sm.DivisionId,
                --tm.TeacherId AS 'ClassTeacherId',
                 STUFF((SELECT CONCAT(', ', t.FirstName, ' ', t.MiddleName, ' ', t.LastName) 
                               FROM Teacher t
                               JOIN TeacherGradeDivisionMapping tm ON t.TeacherId = tm.TeacherId
                               WHERE tm.GradeId = sm.GradeId AND tm.DivisionId = sm.DivisionId AND t.IsDeleted <> 1 AND tm.AcademicYearId = @AcademicYearId
                               FOR XML PATH('')), 1, 2, '') AS 'ClassTeacherName',
                CASE 
                    WHEN sa.AttendanceDateTime IS NULL THEN 'Not Taken' 
                    WHEN sa.AttendanceDateTime != dm.WorkingDays THEN 'Not Matched'
                    ELSE 'Taken' 
                END AS 'Status'
	                FROM
             (SELECT DISTINCT d.WorkingDays FROM dbo.udfGetSchoolWorkingDaysUptoCurrentDate(@AcademicYearId) d WHERE d.WorkingDays <@CurrentDateTime  ) dm
            CROSS JOIN
                SchoolGradeDivisionMatrix sm
	              INNER JOIN Grade g ON sm.GradeId = g.GradeId
                    INNER JOIN Division d ON sm.DivisionId = d.DivisionId
            INNER JOIN   
                TeacherGradeDivisionMapping tm ON sm.GradeId = tm.GradeId AND sm.DivisionId = tm.DivisionId
            INNER JOIN
                Teacher t ON tm.TeacherId = t.TeacherId
            LEFT JOIN   
                StudentAttendance sa ON sa.AttendanceDateTime = dm.WorkingDays and sa.GradeId = tm.GradeId and sa.DivisionId=tm.DivisionId
       
             WHERE 
                sm.AcademicYearId = @AcademicYearId
                AND tm.AcademicYearId = @AcademicYearId
                AND sa.AttendanceDateTime IS NULL 
                AND ISNULL(sm.IsDeleted,0)<>1
                AND ISNULL(tm.IsDeleted,0)<>1
                AND ISNULL(t.IsDeleted,0)<>1
                AND ISNULL(sa.IsDeleted,0)<>1 
                AND tm.AcademicYearId=@AcademicYearId
                 ORDER BY
                        dm.WorkingDays DESC;
      END
      ELSE 
      IF @RoleId = 3
      BEGIN
       SELECT DISTINCT
                dm.WorkingDays AS 'AttendanceMissingDate',
               sm.GradeId,
               g.GradeName,
               d.DivisionName,
               sm.DivisionId,
                --tm.TeacherId AS 'ClassTeacherId',
                 STUFF((SELECT CONCAT(', ', t.FirstName, ' ', t.MiddleName, ' ', t.LastName) 
                               FROM Teacher t
                               JOIN TeacherGradeDivisionMapping tm ON t.TeacherId = tm.TeacherId
                               WHERE tm.GradeId = sm.GradeId AND tm.DivisionId = sm.DivisionId  AND t.IsDeleted <> 1 AND tm.AcademicYearId = @AcademicYearId
                               FOR XML PATH('')), 1, 2, '') AS 'ClassTeacherName',
                CASE 
                    WHEN sa.AttendanceDateTime IS NULL THEN 'Not Taken' 
                    WHEN sa.AttendanceDateTime != dm.WorkingDays THEN 'Not Matched'
                    ELSE 'Taken' 
                END AS 'Status'
	                FROM
             (SELECT DISTINCT d.WorkingDays FROM dbo.udfGetSchoolWorkingDaysUptoCurrentDate(@AcademicYearId) d WHERE d.WorkingDays <@CurrentDateTime) dm
            CROSS JOIN
                SchoolGradeDivisionMatrix sm
	              INNER JOIN Grade g ON sm.GradeId = g.GradeId
                    INNER JOIN Division d ON sm.DivisionId = d.DivisionId
            INNER JOIN   
                TeacherGradeDivisionMapping tm ON sm.GradeId = tm.GradeId AND sm.DivisionId = tm.DivisionId AND tm.TeacherId = @RefId
            INNER JOIN
                Teacher t ON tm.TeacherId = t.TeacherId  AND tm.TeacherId = @RefId
            LEFT JOIN   
                StudentAttendance sa ON sa.AttendanceDateTime = dm.WorkingDays and sa.GradeId = tm.GradeId and sa.DivisionId=tm.DivisionId
       
             WHERE 
                sm.AcademicYearId = @AcademicYearId AND
                sa.AttendanceDateTime IS NULL 
                AND ISNULL(sm.IsDeleted,0)<>1
                AND ISNULL(tm.IsDeleted,0)<>1
                AND ISNULL(t.IsDeleted,0)<>1
                AND ISNULL(sa.IsDeleted,0)<>1 
                AND tm.AcademicYearId=@AcademicYearId
                 ORDER BY
                        dm.WorkingDays DESC;
      END
        
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
    END CATCH 
END;

