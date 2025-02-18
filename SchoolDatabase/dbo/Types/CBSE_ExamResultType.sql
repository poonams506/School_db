CREATE TYPE [dbo].[CBSE_ExamResultType] AS TABLE
(
	StudentId SMALLINT,
	ExamObjectId BIGINT,
	OutOfMarks SMALLINT,
	ActualMarks DECIMAL(18,2),
	TotalMarks DECIMAL(18,2),
	Percentage DECIMAL(18,2),
	Grade NVARCHAR(5)
)