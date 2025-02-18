CREATE TABLE [dbo].[Notice]
(
    NoticeId BIGINT IDENTITY(1, 1),
    AcademicYearId SMALLINT,
    IsImportant BIT DEFAULT(0) NOT NULL,
    Title NVARCHAR(1000),
    Description NVARCHAR(MAX),
    StartDate DATETIME,
    EndDate DATETIME,
    NoticeToType INT,
    CreatedBy INT,
    CreatedDate DATETIME,
    ModifiedBy INT,
    ModifiedDate DATETIME,
    IsDeleted BIT DEFAULT(0) NOT NULL,
    IsPublished BIT DEFAULT (0) NOT NULL,
  
    CONSTRAINT [PKNotice] PRIMARY KEY (NoticeId), 
    CONSTRAINT [FKNoticeAcademicYear] FOREIGN KEY (AcademicYearId) REFERENCES AcademicYear(AcademicYearId)
);
