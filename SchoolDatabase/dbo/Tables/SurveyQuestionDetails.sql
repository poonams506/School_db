CREATE TABLE [dbo].[SurveyQuestionDetails]
(
	  SurveyQuestionDetailsId BIGINT IDENTITY(1, 1),
	  SurveyId BIGINT,
	  SurveyQuestions NVARCHAR(1000),
      CreatedBy INT,
      CreatedDate DATETIME,
      ModifiedBy INT,
      ModifiedDate DATETIME,
      IsDeleted BIT DEFAULT(0) NOT NULL,
      CONSTRAINT [PKSurveyQuestionDetails] PRIMARY KEY (SurveyQuestionDetailsId),
      CONSTRAINT [FKSurveyQuestionDetailsSurvey] FOREIGN KEY (SurveyId) REFERENCES Survey(SurveyId) 

)
