--===============================================
-- Author:    Prerana Aher
-- Create date: 27/08/2024
-- Description:  This stored procedure is used to get Upcoming Teacher Lecture in next 10min by Select  
-- =============================================
CREATE PROCEDURE [dbo].[uspUpcomingTeacherLectureSelect]
(
	@AcademicYearId INT
)
AS 
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    DECLARE @CurrentDateTime DATETIME;
    SET @CurrentDateTime = GETDATE();
    BEGIN TRY 

SELECT DISTINCT
ctcd.TeacherId,
sm.SubjectName,
CONCAT(g.GradeName, '-' , d.DivisionName) AS ClassName

FROM
dbo.ClassTimeTable as ct
	
		Inner Join dbo.ClassTimeTableColumnDetail ctcd on ctcd.ClassTimeTableId = ct.ClassTimeTableId
		Inner Join dbo.ClassTimeTableRowDetail as ctr on ctcd.ClassTimeTableRowDetailId = ctr.ClassTimeTableRowDetailId
		INNER JOIN dbo.Grade g ON ct.GradeId = g.GradeId
        INNER JOIN dbo.Division d ON ct.DivisionId = d.DivisionId
		INNER JOIN dbo.SubjectMaster as sm on ctcd.SubjectId = sm.SubjectMasterId
		INNER JOIN dbo.Teacher t ON ctcd.TeacherId = t.TeacherId
		
WHERE
	ct.AcademicYearId = @AcademicYearId AND
	ct.isActive = 1 AND
	ct.IsDeleted <> 1 
	AND DATETIMEFROMPARTS(
    YEAR(GETDATE()),   
    MONTH(GETDATE()),  
    DAY(GETDATE()),    
    ctr.StartingHour,  
    ctr.StartingMinute,
    0,                 
    0                  
)
	BETWEEN @CurrentDateTime and DATEADD(MINUTE, 60, @CurrentDateTime)
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
END