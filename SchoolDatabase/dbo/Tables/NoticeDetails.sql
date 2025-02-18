CREATE TABLE [dbo].[NoticeDetails]
(
    NoticeDetailsId BIGINT IDENTITY(1, 1),
    NoticeId BIGINT,
    FileName NVARCHAR(100),
    FileType INT,
    CreatedBy INT,
    CreatedDate DATETIME,
    ModifiedBy INT,
    ModifiedDate DATETIME,
    IsDeleted BIT DEFAULT(0) NOT NULL,
    
    CONSTRAINT [PKNoticeDetails] PRIMARY KEY (NoticeDetailsId),
    CONSTRAINT [FKNoticeDetailsNotice] FOREIGN KEY (NoticeId) REFERENCES Notice(NoticeId) 
);

