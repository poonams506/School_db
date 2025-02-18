CREATE TABLE [dbo].[SchoolEventDetails]
(
	SchoolEventDetailsId INT NOT NULL IDENTITY(1,1),
    SchoolEventId  SMALLINT,
	FileName NVARCHAR(100),
    FileType INT,
    CreatedBy INT,
    CreatedDate DATETIME,
    ModifiedBy INT,
    ModifiedDate DATETIME,
    IsDeleted BIT DEFAULT(0) NOT NULL,
     CONSTRAINT [PKSchoolEventDetails] PRIMARY KEY (SchoolEventDetailsId),
    CONSTRAINT [FKSchoolEventDetails] FOREIGN KEY (SchoolEventId) REFERENCES SchoolEvent(SchoolEventId) 
)
