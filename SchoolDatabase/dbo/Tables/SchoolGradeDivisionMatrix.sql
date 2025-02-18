CREATE TABLE SchoolGradeDivisionMatrix (
  SchoolGradeDivisionMatrixId INT IDENTITY(1, 1), 
  GradeId SMALLINT, 
  DivisionId SMALLINT,
  AcademicYearId SMALLINT,
  CreatedBy INT, 
  CreatedDate DATETIME, 
  ModifiedBy INT, 
  ModifiedDate DATETIME, 
  IsDeleted BIT DEFAULT(0) NOT NULL,
  CONSTRAINT [PKGradeDivisionMatrix] PRIMARY KEY CLUSTERED ([SchoolGradeDivisionMatrixId] ASC),
  CONSTRAINT [FKSchoolGradeDivisionMatrixGrade] FOREIGN KEY (GradeId) REFERENCES Grade(GradeId),
  CONSTRAINT [FKSchoolGradeDivisionMatrixDivision] FOREIGN KEY (DivisionId) REFERENCES Division(DivisionId),
  CONSTRAINT [FKSchoolGradeDivisionMatrixAcademicYear] FOREIGN KEY (AcademicYearId) REFERENCES AcademicYear(AcademicYearId)
);