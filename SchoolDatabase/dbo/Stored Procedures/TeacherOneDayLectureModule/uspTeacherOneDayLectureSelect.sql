-- =============================================
-- Author: Saurabh Walunj
-- Create date: 18/03/2024
-- Description: This stored procedure is used to get school teacher one day lecture
-- =============================================
CREATE PROC [dbo].[uspTeacherOneDayLectureSelect] (@AcademicYearId INT, @TeacherId INT, @DayNo INT) AS 
BEGIN 
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    BEGIN TRY 


   SELECT 
	    CONCAT(t.FirstName, ' ', t.MiddleName, ' ', t.LastName) AS TeacherName,
		CASE WHEN ctr.StartingHour = 12 THEN CONCAT(ctr.StartingHour,':', RIGHT('0' + CONVERT(VARCHAR, ctr.StartingMinute), 2), 'PM')
		WHEN ctr.StartingHour > 12 THEN CONCAT(ctr.StartingHour - 12,':', RIGHT('0' + CONVERT(VARCHAR, ctr.StartingMinute), 2), 'PM') 
		ELSE CONCAT(ctr.StartingHour,':', RIGHT('0' + CONVERT(VARCHAR, ctr.StartingMinute), 2), 'AM') END As StartTime,

		CASE WHEN ctr.EndingHour = 12 THEN CONCAT(ctr.EndingHour,':', RIGHT('0' + CONVERT(VARCHAR, ctr.EndingMinute), 2), 'PM')
		WHEN ctr.EndingHour > 12 THEN CONCAT(ctr.EndingHour - 12,':',RIGHT('0' + CONVERT(VARCHAR, ctr.EndingMinute), 2), 'PM') 
		ELSE CONCAT(ctr.EndingHour,':', RIGHT('0' + CONVERT(VARCHAR, ctr.EndingMinute), 2), 'AM') END As EndTime,


		ct.GradeId,
		g.GradeName,
		ct.DivisionId,
		d.DivisionName,
		ctcd.DayNo,
		ctcd.SubjectId,
		sm.SubjectName
			
		
	FROM dbo.ClassTimeTableColumnDetail ctcd
		Inner Join dbo.ClassTimeTable as ct on ctcd.ClassTimeTableId = ct.ClassTimeTableId
		Inner Join dbo.ClassTimeTableRowDetail as ctr on ctcd.ClassTimeTableRowDetailId = ctr.ClassTimeTableRowDetailId
        INNER JOIN dbo.Grade g ON ct.GradeId = g.GradeId
        INNER JOIN dbo.Division d ON ct.DivisionId = d.DivisionId
		INNER JOIN dbo.SubjectMaster as sm on ctcd.SubjectId = sm.SubjectMasterId
		INNER JOIN dbo.Teacher t ON ctcd.TeacherId = t.TeacherId
		INNER JOIN dbo.SchoolGradeDivisionMatrix as sgdm ON g.GradeId = sgdm.GradeId AND d.DivisionId = sgdm.DivisionId 

		
	WHERE 
	  ctcd.TeacherId = @TeacherId AND ctcd.IsDeleted <> 1 AND ctr.IsDeleted <> 1 AND sgdm.IsDeleted <> 1
	  AND ct.AcademicYearId = @AcademicYearId
	  AND ctcd.DayNo = @DayNo
	  AND ct.isActive = 1
		AND ct.IsDeleted<> 1
		AND sgdm.AcademicYearId = @AcademicYearId

		ORDER BY ctr.StartingHour,ctr.StartingMinute;


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