CREATE TABLE [dbo].[NoticeMediaDetails]
(
	NoticeMediaDetailsId BIGINT IDENTITY(1, 1),
    NoticeId BIGINT,
    ContentUrl NVARCHAR(1000),
    FileType INT,
    CreatedBy INT,
    CreatedDate DATETIME,
    ModifiedBy INT,
    ModifiedDate DATETIME,
    IsDeleted BIT DEFAULT(0) NOT NULL,
    
    CONSTRAINT [PKNoticeMediaDetails] PRIMARY KEY (NoticeMediaDetailsId),
    CONSTRAINT [FKNoticeMediaDetailsNotice] FOREIGN KEY (NoticeId) REFERENCES Notice(NoticeId) 
)
