CREATE TABLE [dbo].[TeacherGradeDivisionMapping]
(
  TeacherGradeDivisionMappingId BIGINT IDENTITY(1, 1), 
  TeacherId BIGINT, 
  AcademicYearId SMALLINT,
  GradeId SMALLINT, 
  DivisionId SMALLINT, 
  CreatedBy INT, 
  CreatedDate DATETIME, 
  ModifiedBy INT, 
  ModifiedDate DATETIME, 
  IsDeleted BIT DEFAULT(0) NOT NULL,
  CONSTRAINT [PKTeacherGradeDivisionMapping] PRIMARY KEY CLUSTERED ([TeacherGradeDivisionMappingId] ASC),
  CONSTRAINT [FKTeacherGradeDivisionMappingTeacher] FOREIGN KEY (TeacherId) REFERENCES Teacher(TeacherId),
  CONSTRAINT [FKTeacherGradeDivisionMappingAcademicYear] FOREIGN KEY (AcademicYearId) REFERENCES AcademicYear(AcademicYearId),
  CONSTRAINT [FKTeacherGradeDivisionMappingGrade] FOREIGN KEY (GradeId) REFERENCES Grade(GradeId),
  CONSTRAINT [FKTeacherGradeDivisionMappingDivision] FOREIGN KEY (DivisionId) REFERENCES Division(DivisionId),

)
