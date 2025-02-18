CREATE TABLE [dbo].[HomeworkMediaDetail]
(
	HomeworkMediaDetailId BIGINT IDENTITY(1, 1),
    HomeWorkId BIGINT,
    ContentUrl NVARCHAR(1000),
    CreatedBy INT,
    CreatedDate DATETIME,
    ModifiedBy INT,
    ModifiedDate DATETIME,
    IsDeleted BIT DEFAULT(0) NOT NULL,
    
    CONSTRAINT [PKHomeworkMediaDetail] PRIMARY KEY (HomeworkMediaDetailId),
    CONSTRAINT [FKNoticeMediaDetailHomeWork] FOREIGN KEY (HomeWorkId) REFERENCES HomeWork(HomeWorkId) 
)
