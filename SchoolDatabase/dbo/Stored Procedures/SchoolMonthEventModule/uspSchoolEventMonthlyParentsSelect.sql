-- =============================================
-- Author: Saurabh Walunj
-- Create date: 07/03/2024
-- Description: This stored procedure is used to get school event parents Monthly data
-- =============================================
CREATE PROCEDURE uspSchoolEventMonthlyParentsSelect (@AcademicYearId INT, @GradeId INT, @DivisionId INT) AS 
BEGIN 
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    BEGIN TRY 
        DECLARE @CurrentDateTime DATETIME = GETDATE();
        DECLARE @Next30Days DATETIME;

        SET @Next30Days = DATEADD(DAY, 30, @CurrentDateTime);

       WITH RecursiveEvents AS (
    SELECT 
        e.SchoolEventId,
        e.AcademicYearId,
        e.EventTitle,
        e.EventDescription,
        e.EventFess,
        e.EventVenue,
        e.EventCoordinator,
        e.IsCompulsory,
        e.IsPublished,
        CASE 
            WHEN StartDate >= CAST(GETDATE() AS DATE) THEN StartDate -- If event starts from today or later, use the StartDate
            ELSE CAST(GETDATE() AS DATE) -- If event started before today, use today's date as the EventDate
        END AS EventDate,
        EndDate,
		e.StartTime,
        e.EndTime
    FROM dbo.SchoolEvent e
	inner join SchoolEventMapping as sem on e.SchoolEventId = sem.SchoolEventId
            INNER JOIN Grade g ON sem.GradeId = g.GradeId
            INNER JOIN Division d ON sem.DivisionId = d.DivisionId
    WHERE 
        e.IsDeleted <> 1
        AND IsPublished = 1
        AND AcademicYearId = @AcademicYearId
		AND sem.GradeId = @GradeId and sem.DivisionId = @DivisionId
        AND StartDate <= DATEADD(DAY, 30, GETDATE()) -- Events starting within the next 30 days
        AND EndDate >= GETDATE() -- Events ending on or after the current date
    UNION ALL
    SELECT 
        se.SchoolEventId,
        se.AcademicYearId,
        se.EventTitle,
        se.EventDescription,
        se.EventFess,
        se.EventVenue,
        se.EventCoordinator,
        se.IsCompulsory,
        se.IsPublished,
        DATEADD(DAY, 1, re.EventDate) AS EventDate, -- Increment the date by 1 day
        re.EndDate,
	    re.StartTime,
        re.EndTime
    FROM RecursiveEvents re
    INNER JOIN dbo.SchoolEvent se ON re.SchoolEventId = se.SchoolEventId
    WHERE 
        DATEADD(DAY, 1, re.EventDate) <= re.EndDate -- Ensure that the incremented date is within the event's end date
)

SELECT 
    re.SchoolEventId,
    re.AcademicYearId,
    re.EventTitle,
    re.EventDescription,
    re.EventFess,
    re.EventVenue,
    re.EventCoordinator,
    re.IsCompulsory,
    re.IsPublished,
    re.EventDate AS StartDate,
    re.EndDate,
    se.StartTime,
    se.EndTime,
    STUFF((SELECT ', ' + CAST(sgdm.SchoolGradeDivisionMatrixId AS NVARCHAR)
           FROM dbo.SchoolEventMapping sem
           INNER JOIN dbo.SchoolGradeDivisionMatrix sgdm ON sem.GradeId = sgdm.GradeId 
                                                      AND sem.DivisionId = sgdm.DivisionId 
                                                      AND sgdm.AcademicYearId = re.AcademicYearId
           WHERE sem.SchoolEventId = re.SchoolEventId
           FOR XML PATH('')), 1, 2, '') AS ClassId
FROM 
    RecursiveEvents re
    INNER JOIN dbo.SchoolEvent se ON re.SchoolEventId = se.SchoolEventId
WHERE 
    se.IsDeleted <> 1
    AND (
        re.EventDate > CAST(GETDATE() AS DATE)
        OR (re.EventDate = CAST(GETDATE() AS DATE) AND ( se.EndTime IS NULL OR CAST(se.EndTime AS TIME) > CAST(GETDATE() AS TIME)))
    )
ORDER BY 
    re.EventDate ASC,
    re.SchoolEventId,  
    se.StartTime
    OPTION (MAXRECURSION 32767);


			

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


