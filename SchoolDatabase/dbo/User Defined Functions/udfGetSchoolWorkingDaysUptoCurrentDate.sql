CREATE FUNCTION dbo.udfGetSchoolWorkingDaysUptoCurrentDate
(
    @AcademicYearId INT
)
RETURNS @WorkingDaysTable TABLE
(
    WorkingDays DATETIME
)
AS
BEGIN
    
    DECLARE @StartDate DATETIME = (SELECT AcademicYearStartMonth FROM SchoolSetting WHERE AcademicYearId = @AcademicYearId AND IsDeleted <> 1)
    DECLARE @EndDate DATETIME = CONVERT(DATE, GETDATE())
	

	;WITH DateRange AS (
    SELECT @StartDate AS Date
    UNION ALL
    SELECT DATEADD(day, 1, Date)
    FROM DateRange
    WHERE Date < @EndDate
    )

	INSERT INTO @WorkingDaysTable
	SELECT Date
	FROM DateRange
	OPTION (MAXRECURSION 0);

	DELETE FROM @WorkingDaysTable WHERE WorkingDays IN (SELECT DISTINCT Holidays FROM dbo.udfGetSchoolHolidays(@AcademicYearId))
    
    RETURN;
END;