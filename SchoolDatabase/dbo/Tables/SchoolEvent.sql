CREATE TABLE [dbo].[SchoolEvent]
(
    SchoolEventId SMALLINT IDENTITY(1,1),
    AcademicYearId SMALLINT,
    EventTitle NVARCHAR (1000),
    EventDescription NVARCHAR(1000),
    EventFess MONEY,
    EventVenue NVARCHAR(1000),
	EventCoordinator NVARCHAR(1000),
    StartDate DATETIME,
    EndDate DATETIME,
    StartTime DATETIME,
    EndTime DATETIME,
    IsCompulsory BIT DEFAULT(0) NOT NULL,
    IsPublished BIT DEFAULT (0) NOT NULL,
    CreatedBy INT,
    CreatedDate DATETIME,
    ModifiedBy INT,
    ModifiedDate DATETIME,
    IsDeleted BIT DEFAULT (0) NOT NULL 
    CONSTRAINT [PKEventId] PRIMARY KEY (SchoolEventId), 
    CONSTRAINT [FKEventAcademicYear] FOREIGN KEY (AcademicYearId) REFERENCES AcademicYear(AcademicYearId)
)
