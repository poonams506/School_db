CREATE TABLE [dbo].[ClassTimeTableColumnDetail]
(
	[ClassTimeTableColumnDetailId] INT NOT NULL IDENTITY(1,1),
	[ClassTimeTableId] INT,
	[ClassTimeTableRowDetailId] INT,
	[DayNo] INT,
	[SubjectId] INT,
	[TeacherId] BIGINT,
	[CreatedBy] INT,
    [CreatedDate] DATETIME,
    [ModifiedBy] INT,
    [ModifiedDate] DATETIME,
	[IsDeleted] BIT DEFAULT((0)) NOT NULL,
	CONSTRAINT [PKClassTimeTableColumnDetail] PRIMARY KEY CLUSTERED ([ClassTimeTableColumnDetailId] ASC),
	CONSTRAINT [FKClassTimeTableColumnDetailSubjectMaster] FOREIGN KEY (SubjectId) REFERENCES SubjectMaster(SubjectMasterId),
	CONSTRAINT [FKClassTimeTableColumnDetailTeacher] FOREIGN KEY (TeacherId) REFERENCES Teacher(TeacherId)

)
