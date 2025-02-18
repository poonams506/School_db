CREATE TABLE [dbo].[Survey]
(
	SurveyId BIGINT IDENTITY(1, 1),
    AcademicYearId SMALLINT,
    IsImportant BIT DEFAULT(0) NOT NULL,
    Title NVARCHAR(1000),
    Description NVARCHAR(MAX),
    StartDate DATETIME,
    EndDate DATETIME,
    SurveyToType INT,
    CreatedBy INT,
    CreatedDate DATETIME,
    ModifiedBy INT,
    ModifiedDate DATETIME,
    IsDeleted BIT DEFAULT(0) NOT NULL,
    IsPublished BIT DEFAULT (0) NOT NULL,
  
    CONSTRAINT [PKSurvey] PRIMARY KEY (SurveyId), 
    CONSTRAINT [FKSurveyAcademicYear] FOREIGN KEY (AcademicYearId) REFERENCES AcademicYear(AcademicYearId)
)
