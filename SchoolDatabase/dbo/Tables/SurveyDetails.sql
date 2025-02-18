CREATE TABLE [dbo].[SurveyDetails]
(
    SurveyDetailsId BIGINT IDENTITY(1, 1),
    SurveyId BIGINT,
    FileName NVARCHAR(100),
    FileType INT,
    CreatedBy INT,
    CreatedDate DATETIME,
    ModifiedBy INT,
    ModifiedDate DATETIME,
    IsDeleted BIT DEFAULT(0) NOT NULL,
    
    CONSTRAINT [PKSurveyDetails] PRIMARY KEY (SurveyDetailsId),
    CONSTRAINT [FKSurveyDetailsSurvey] FOREIGN KEY (SurveyId) REFERENCES Survey(SurveyId) 
)
