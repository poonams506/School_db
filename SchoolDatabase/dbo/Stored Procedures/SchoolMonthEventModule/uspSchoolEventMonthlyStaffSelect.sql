-- =============================================
-- Author: Saurabh Walunj
-- Create date: 07/03/2024
-- Description: This stored procedure is used to get school event staff Monthly data
-- =============================================
CREATE PROC dbo.uspSchoolEventMonthlyStaffSelect (@AcademicYearId INT) AS 
BEGIN 
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
    SET NOCOUNT ON;

    BEGIN TRY 
        DECLARE @CurrentDateTime DATETIME = GETDATE();
        DECLARE @Next30Days DATETIME;

        SET @Next30Days = DATEADD(DAY, 30, @CurrentDateTime);

        WITH RecursiveEvents AS (
    SELECT 
        SchoolEventId,
        AcademicYearId,
        EventTitle,
        EventDescription,
        EventFess,
        EventVenue,
        EventCoordinator,
        IsCompulsory,
        IsPublished,
        CASE 
            WHEN StartDate >= CAST(GETDATE() AS DATE) THEN StartDate
            ELSE CAST(GETDATE() AS DATE)
        END AS EventDate,
        EndDate,
        StartTime,
        EndTime
    FROM dbo.SchoolEvent
    WHERE 
        IsDeleted <> 1
        AND IsPublished = 1
        AND AcademicYearId = @AcademicYearId
        AND StartDate <= DATEADD(DAY, 30, GETDATE())
        AND (
            EndDate > CAST(GETDATE() AS DATE)
            OR (EndDate = CAST(GETDATE() AS DATE) AND (EndTime IS NULL OR CAST(EndTime AS TIME) > CAST(GETDATE() AS TIME)))
        )
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
        DATEADD(DAY, 1, re.EventDate) AS EventDate,
        re.EndDate,
        re.StartTime,
        re.EndTime
    FROM RecursiveEvents re
    INNER JOIN dbo.SchoolEvent se ON re.SchoolEventId = se.SchoolEventId
    WHERE 
        DATEADD(DAY, 1, re.EventDate) <= re.EndDate
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
    re.StartTime,
    re.EndTime,
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
        OR (re.EventDate = CAST(GETDATE() AS DATE) AND (re.EndTime IS NULL OR CAST(re.EndTime AS TIME) > CAST(GETDATE() AS TIME)))
		)

ORDER BY 
    re.EventDate ASC,
    re.SchoolEventId,  
    re.StartTime
    OPTION (MAXRECURSION 32767);

 -- Select School Event Details
 SELECT 
     se.SchoolEventId,
     sed.SchoolEventDetailsId,
     sed.FileName
 FROM 
     dbo.SchoolEvent se 
    INNER JOIN dbo.SchoolEventDetails sed ON se.SchoolEventId = sed.SchoolEventId
 WHERE 
     se.AcademicYearId = @AcademicYearId
     AND se.IsPublished = 1 
     AND se.IsDeleted <>1
     AND sed.IsDeleted<>1

SELECT 
     se.SchoolEventId,
    se.StartDate AS 'EventStartDate',
    se.EndDate AS 'EventEndDate'
 FROM 
     dbo.SchoolEvent se 
 WHERE 
     se.AcademicYearId = @AcademicYearId
     AND se.IsPublished = 1 
     AND se.IsDeleted <>1

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
