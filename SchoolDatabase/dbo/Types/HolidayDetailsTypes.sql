
CREATE TYPE [dbo].[HolidayDetailsTypes] AS TABLE
(
    SchoolHolidayId BIGINT,
    CalendarDate DATETIME,
    HolidayReason NVARCHAR(100),
    DayNo INT
)


