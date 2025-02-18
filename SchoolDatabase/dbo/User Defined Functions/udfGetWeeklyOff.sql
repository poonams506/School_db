CREATE FUNCTION dbo.udfGetWeeklyOff
(
    @AcademicYearId INT
)
RETURNS @HolidayTable TABLE
(
    WeeklyOffName VARCHAR(100),
    Holidays DATETIME,
    AcademicYearId INT
)
AS
BEGIN
    DECLARE @StartDate DATETIME = (SELECT AcademicYearStartMonth FROM SchoolSetting WHERE AcademicYearId = @AcademicYearId AND IsDeleted <> 1)
    DECLARE @EndDate DATETIME =  DATEADD(DAY, 30, GETDATE())

   
    ;WITH DateRange AS (
        SELECT @StartDate AS DateValue
        UNION ALL
        SELECT DATEADD(DAY, 1, DateValue)
        FROM DateRange
        WHERE DateValue < @EndDate
    )
    INSERT INTO @HolidayTable (WeeklyOffName, Holidays,AcademicYearId)
    SELECT 
        CASE 
            WHEN DATEPART(WEEKDAY, DateValue) = 1 THEN 'School Weekly Off'
            WHEN DATEPART(WEEKDAY, DateValue) = 2 THEN 'School Weekly Off'
            WHEN DATEPART(WEEKDAY, DateValue) = 3 THEN 'School Weekly Off'
            WHEN DATEPART(WEEKDAY, DateValue) = 4 THEN 'School Weekly Off'
            WHEN DATEPART(WEEKDAY, DateValue) = 5 THEN 'School Weekly Off'
            WHEN DATEPART(WEEKDAY, DateValue) = 6 THEN 'School Weekly Off'
            WHEN DATEPART(WEEKDAY, DateValue) = 7 THEN 'School Weekly Off'
        END AS WeeklyOffName,
        DateValue AS HolidayDate,
         @AcademicYearId AS AcademicYearId

    FROM DateRange
    INNER JOIN [dbo].[WeeklyOff] wo ON wo.AcademicYearId = @AcademicYearId 
                                     AND wo.DayNo = DATEPART(WEEKDAY, DateValue)
    OPTION (MAXRECURSION 0);

    RETURN;
END;