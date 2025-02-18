﻿CREATE TABLE [dbo].[StudentEnquiry]
(
	StudentEnquiryId INT IDENTITY(1,1) NOT NULL,
	EnquiryDate DATE,
	StudentFirstName NVARCHAR(50),
	StudentMiddleName NVARCHAR(50),
	StudentLastName NVARCHAR(50),
	Gender NVARCHAR(5),
	BirthDate DATE,
	AdharNo NVARCHAR(20),
	Religion NVARCHAR(50),
	Cast NVARCHAR(50),
	Category NVARCHAR(50),
	Nationality NVARCHAR(50),
	MobileNumber NVARCHAR(20),
	InterestedClassId INT,
	AcademicYearId SMALLINT,
	CurrentSchool NVARCHAR(250),
	CurrentClass NVARCHAR(20),
	NameOfSiblingInCurrentSchool NVARCHAR(50),
	FatherFirstName NVARCHAR(50),
	FatherMiddleName NVARCHAR(50),
	FatherLastName NVARCHAR(50),
	MotherFirstName NVARCHAR(50),
	MotherMiddleName NVARCHAR(50),
	MotherLastName NVARCHAR(50),
	AddressLine1 NVARCHAR(250),
	AddressLine2 NVARCHAR(250),
	CountryId INT,
	CountryName NVARCHAR(100),
	StateId INT,
	StateName NVARCHAR(100),
	TalukaId INT,
	TalukaName NVARCHAR(100),
	DistrictId INT,
	DistrictName NVARCHAR(100),
	EnquiryTypeId SMALLINT,
	ReferenceBy NVARCHAR(50),
	EnquiryStatusId INT,
	EmailId VARCHAR(80),
	CreatedBy INT,
	CreatedDate DATETIME,
	ModifiedBy INT,
	ModifiedDate DATETIME,
	IsDeleted BIT DEFAULT(0) NOT NULL
	CONSTRAINT [PKStudentEnquiry] PRIMARY KEY (StudentEnquiryId),
	CONSTRAINT [FKStudentEnquiryCountry] FOREIGN KEY (CountryId) REFERENCES Country(CountryId),
	CONSTRAINT [FKStudentEnquiryState] FOREIGN KEY (StateId) REFERENCES State(StateId),
	CONSTRAINT [FKStudentEnquiryTaluka] FOREIGN KEY (TalukaId) REFERENCES Taluka(TalukaId),
	CONSTRAINT [FKStudentEnquiryDistrict] FOREIGN KEY (DistrictId) REFERENCES District(DistrictId),
	CONSTRAINT [FKStudentEnquiryAcademicYear] FOREIGN KEY (AcademicYearId) REFERENCES AcademicYear(AcademicYearId)
)
