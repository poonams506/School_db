CREATE TABLE [dbo].[WeeklyOff]
(
	[WeeklyOffId] BIGINT IDENTITY(1, 1),
	[DayNo]  NVARCHAR(100) NOT NULL,
	[AcademicYearId] SMALLINT,
	CreatedBy INT, 
	CreatedDate DATETIME, 
	ModifiedBy INT, 
	ModifiedDate DATETIME, 
	IsDeleted BIT DEFAULT(0) NOT NULL,
    CONSTRAINT [PKWeeklyOff] PRIMARY KEY (WeeklyOffId),
	CONSTRAINT [FKWeeklyOffAcademicYear] FOREIGN KEY (AcademicYearId) REFERENCES AcademicYear(AcademicYearId),
)
