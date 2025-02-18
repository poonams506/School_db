CREATE TABLE [dbo].[SchoolTransportSetting]
(
	SchoolTransportSettingId INT IDENTITY (1, 1),
	SchoolId SMALLINT , 
	MonthId INT,
	AcademicYearId SMALLINT,
	CreatedBy INT, 
	CreatedDate DATETIME, 
	ModifiedBy INT, 
	ModifiedDate DATETIME, 
	[IsDeleted] BIT DEFAULT(0) NOT NULL,
	CONSTRAINT [PKSchoolTransportSetting] PRIMARY KEY CLUSTERED ([SchoolTransportSettingId] ASC),
	CONSTRAINT [FKSchoolTransportSettingSchool] FOREIGN KEY (SchoolId) REFERENCES School(SchoolId)

)
