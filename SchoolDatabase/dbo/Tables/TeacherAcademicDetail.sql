CREATE TABLE [dbo].[TeacherAcademicDetail]
(   
    TeacherAcademicDetailId INT NOT NULL IDENTITY(1,1),
	AcademicYearId SMALLINT,
	TeacherId BIGINT, 
	LecturePerWeek INT,
    CreatedBy INT,
    CreatedDate DATETIME,
    ModifiedBy INT,
    ModifiedDate DATETIME,
    CONSTRAINT [PKTeacherAcademicDetail] PRIMARY KEY (TeacherAcademicDetailId),
    CONSTRAINT [FKTeacherAcademicDetailAcademicYear] FOREIGN KEY (AcademicYearId) REFERENCES AcademicYear(AcademicYearId),
    CONSTRAINT [FKTeacherAcademicDetailTeacher] FOREIGN KEY (TeacherId) REFERENCES Teacher(TeacherId)

)
