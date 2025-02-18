--===============================================
-- Author:- Gulave Pramod 
-- Create date:- 28-08-2024
-- Description:- This stored procedure is used to get the event before 12 hours from the event date for the student.
-- =============================================
CREATE PROCEDURE [dbo].[uspEventSelect]
(
    @AcademicYearId SMALLINT
)
AS 
BEGIN 
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;
	DECLARE @CurrentDateTime DATETIME=GETDATE()
    BEGIN TRY 
SELECT DISTINCT
			se.EventTitle,
			se.EventDescription,
			CONCAT(g.GradeName ,'-', d.DivisionName) AS ClassId
FROM
	 SchoolEvent AS se
	 INNER JOIN SchoolEventMapping AS sem ON se.SchoolEventId = sem.SchoolEventId
	 INNER JOIN Grade AS g ON sem.GradeId=g.GradeId
	 INNER JOIN Division AS d ON sem.DivisionId=d.DivisionId
WHERE
            DATEADD(HOUR, -12, se.StartDate) <= @CurrentDateTime AND
            se.StartDate > @CurrentDateTime AND 
			se.IsPublished = 1 AND
			se.AcademicYearId=@AcademicYearId
            AND se.IsDeleted <> 1
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