CREATE TABLE [dbo].[ParentStudentMapping]
(
	ParentStudentMappingId BIGINT IDENTITY(1, 1),
	ParentId BIGINT , 
    StudentId BIGINT,
	CONSTRAINT [PKParentStudentMapping] PRIMARY KEY CLUSTERED ([ParentStudentMappingId] ASC),
	CONSTRAINT [FKParentStudentMappingParent] FOREIGN KEY (ParentId) REFERENCES Parent(ParentId),
	CONSTRAINT [FKParentStudentMappingStudent] FOREIGN KEY (StudentId) REFERENCES Student(StudentId)
)
