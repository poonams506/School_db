CREATE TABLE [dbo].[SchoolHolidays]
(
    SchoolHolidayId BIGINT IDENTITY(1, 1) NOT NULL,
    AcademicYearId SMALLINT,
    DayNo INT,
    CalendarDate DATETIME,
    HolidayReason NVARCHAR(1000),
    CreatedBy INT,
    CreatedDate DATETIME,
    ModifiedBy INT,
    ModifiedDate DATETIME,
    IsDeleted BIT DEFAULT(0) NOT NULL,
    CONSTRAINT PK_SchoolHolidays PRIMARY KEY CLUSTERED ([SchoolHolidayId]  ASC),
    CONSTRAINT [FKSchoolHolidaysAcademicYear] FOREIGN KEY (AcademicYearId) REFERENCES AcademicYear(AcademicYearId),
);
