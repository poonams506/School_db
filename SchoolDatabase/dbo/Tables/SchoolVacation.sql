CREATE TABLE [dbo].[SchoolVacation]
(
	 SchoolVacationId BIGINT IDENTITY(1, 1) NOT NULL,
	 AcademicYearId SMALLINT, 
	 VacationName NVARCHAR(100),
	 StartDate DATETIME,
     EndDate DATETIME,
	 CreatedBy INT,
     CreatedDate DATETIME,
     ModifiedBy INT,
     ModifiedDate DATETIME,
     IsDeleted BIT DEFAULT(0) NOT NULL,
	 CONSTRAINT [PKSchoolVacation] PRIMARY KEY CLUSTERED ([SchoolVacationId] ASC),
	 CONSTRAINT [FKSchoolVacation] FOREIGN KEY (AcademicYearId) REFERENCES AcademicYear(AcademicYearId),

)
