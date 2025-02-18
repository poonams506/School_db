CREATE TABLE [dbo].[SubjectMaster]
(
	SubjectMasterId  INT IDENTITY(1, 1) NOT NULL,
	SubjectName NVARCHAR(50) NOT NULL,
	CreatedBy INT,
    CreatedDate DATETIME,
    ModifiedBy INT,
    ModifiedDate DATETIME,
	IsDeleted BIT DEFAULT((0)) NOT NULL,
	CONSTRAINT [PKSubjectMaster] PRIMARY KEY CLUSTERED ([SubjectMasterId] ASC)
)


