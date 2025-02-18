CREATE TABLE [dbo].[SchoolSetting]
(
	SchoolSettingId INT IDENTITY (1, 1),
	SchoolId SMALLINT ,
	AcademicYearStartMonth DATETIME,
	IsSharedTransport BIT DEFAULT(0)  NOT NULL,
	IsFeeApplicableToStaff BIT DEFAULT(0)  NOT NULL,
	AcademicYearId SMALLINT,
	CreatedBy INT, 
	CreatedDate DATETIME, 
	ModifiedBy INT, 
	ModifiedDate DATETIME, 
	[IsDeleted] BIT DEFAULT(0) NOT NULL,
	CONSTRAINT [PKSchoolSetting] PRIMARY KEY CLUSTERED ([SchoolSettingId] ASC),
	CONSTRAINT [FKSchoolSettingSchool] FOREIGN KEY (SchoolId) REFERENCES School(SchoolId)

)
