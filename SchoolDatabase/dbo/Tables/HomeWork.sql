CREATE TABLE [dbo].[HomeWork]
(
    HomeWorkId BIGINT IDENTITY(1, 1),
    AcademicYearId SMALLINT,
    GradeId SMALLINT,
    DivisionId SMALLINT,
    SubjectId INT,
    Title NVARCHAR(1000),
    Description NVARCHAR(1000),
    StartDate DATETIME,
    EndDate DATETIME,
    CreatedBy INT,
    CreatedDate DATETIME,
    ModifiedBy INT,
    ModifiedDate DATETIME,
    IsDeleted BIT DEFAULT(0) NOT NULL,
    IsPublished BIT DEFAULT (0) NOT NULL,
  
    CONSTRAINT [PKHomeWork] PRIMARY KEY (HomeWorkId), 
    CONSTRAINT [FKHomeWorkAcademicYear] FOREIGN KEY (AcademicYearId) REFERENCES AcademicYear(AcademicYearId),
    CONSTRAINT [FKHomeWork_Grade] FOREIGN KEY (GradeId) REFERENCES Grade(GradeId),
    CONSTRAINT [FKHomeWorkDivision] FOREIGN KEY (DivisionId) REFERENCES Division(DivisionId),
    CONSTRAINT [FKHomeWorkSubjectMaster] FOREIGN KEY (SubjectId) REFERENCES SubjectMaster(SubjectMasterId)
);
