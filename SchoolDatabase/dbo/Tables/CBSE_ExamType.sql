CREATE TABLE [dbo].[CBSE_ExamType]
(
	ExamTypeId SMALLINT IDENTITY(1,1) NOT NULL,
	ExamTypeName NVARCHAR(200),
	CreatedBy INT,
    CreatedDate DATETIME,
    ModifiedBy INT,
    ModifiedDate DATETIME,
	IsDeleted BIT DEFAULT(0) NOT NULL,

		CONSTRAINT [PKCBSE_ExamType] PRIMARY KEY (ExamTypeId)

)
