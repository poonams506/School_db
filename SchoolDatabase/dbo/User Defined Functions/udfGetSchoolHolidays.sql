CREATE FUNCTION dbo.udfGetSchoolHolidays
(
    @AcademicYearId INT
)
RETURNS @HolidayTable TABLE
(
    Holidays DATETIME
)
AS
BEGIN
    
DECLARE @StartDate DATETIME = (SELECT AcademicYearStartMonth FROM SchoolSetting WHERE AcademicYearId = @AcademicYearId AND IsDeleted <> 1)
DECLARE @EndDate DATETIME = getdate()
;WITH DateRange AS (
    SELECT 
        DATEADD(DAY, DATEDIFF(DAY, 0, @StartDate), 0) AS Holidays
    UNION ALL
    SELECT 
        DATEADD(DAY, 1, Holidays)
    FROM 
        DateRange
    WHERE 
        Holidays < @EndDate
)
INSERT INTO @HolidayTable
SELECT 
    Holidays
FROM 
    DateRange
WHERE 
    DATEPART(WEEKDAY, Holidays) IN (SELECT DayNo FROM  [dbo].[WeeklyOff] WHERE AcademicYearId = @AcademicYearId) -- 1 for Sunday, 7 for Saturday
OPTION (MAXRECURSION 0)
 

INSERT INTO @HolidayTable
SELECT CalendarDate as Holidays FROM [dbo].[SchoolHolidays] WHERE IsDeleted <> 1 AND AcademicYearId = @AcademicYearId


-- Declare cursor
DECLARE @VacationStartDate DATETIME, @VacationEndDate DATETIME
DECLARE vacation_cursor CURSOR FOR
SELECT StartDate,EndDate
FROM [dbo].[SchoolVacation] WHERE IsDeleted <> 1 AND AcademicYearId = @AcademicYearId
-- Open the cursor
OPEN vacation_cursor
-- Fetch the first row into variables
FETCH NEXT FROM vacation_cursor INTO @VacationStartDate, @VacationEndDate
-- Loop through the cursor
WHILE @@FETCH_STATUS = 0
BEGIN
			;WITH DateRange1 AS (
			SELECT 
				DATEADD(DAY, DATEDIFF(DAY, 0, @VacationStartDate), 0) AS Holidays
			UNION ALL
			SELECT 
				DATEADD(DAY, 1, Holidays)
			FROM 
				DateRange1
			WHERE 
				Holidays < @VacationEndDate
		)
		INSERT INTO @HolidayTable
		SELECT 
			Holidays
		FROM 
			DateRange1
		WHERE 
			DATEPART(WEEKDAY, Holidays) IN (1,2,3,4,5,6,7) -- 1 for Sunday, 7 for Saturday
		OPTION (MAXRECURSION 0)
    -- Fetch next row into variables
FETCH NEXT FROM vacation_cursor INTO @VacationStartDate, @VacationEndDate
END
-- Close the cursor
CLOSE vacation_cursor
-- Deallocate the cursor
DEALLOCATE vacation_cursor
-- end
    
    RETURN;
END;