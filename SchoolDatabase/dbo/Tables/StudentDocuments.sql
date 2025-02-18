CREATE TABLE [dbo].[StudentDocuments]
(
	DocumentId BIGINT IDENTITY(1,1),
	DocumentName NVARCHAR(50),
	DocumentUrl NVARCHAR(100),
	DocumentFileType NVARCHAR(50),
	StudentId BIGINT,
	CreatedBy INT, 
	CreatedDate DATETIME, 
	ModifiedBy INT, 
	ModifiedDate DATETIME, 
	IsDeleted BIT DEFAULT(0) NOT NULL, 
	CONSTRAINT [PKStudentDocument] PRIMARY KEY CLUSTERED ([DocumentId] ASC),
  CONSTRAINT [FKStudentDocumentStudent] FOREIGN KEY (StudentId) REFERENCES Student(StudentId)
)
