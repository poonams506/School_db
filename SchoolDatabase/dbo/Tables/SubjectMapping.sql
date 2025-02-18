CREATE TABLE [dbo].[SubjectMapping]
(
    SubjectMappingId BIGINT IDENTITY(1, 1) NOT NULL,
    AcademicYearId SMALLINT,
    GradeId SMALLINT,
    DivisionId SMALLINT,
    IndexNumber SMALLINT, 
    SubjectMasterId INT,
    CreatedBy INT,
    CreatedDate DATETIME,
    ModifiedBy INT,
    ModifiedDate DATETIME,
    IsDeleted BIT DEFAULT(0) NOT NULL,
    CONSTRAINT [PKSubjectMapping] PRIMARY KEY (SubjectMappingId),
    CONSTRAINT [FKSubjectMappingAcademicYear] FOREIGN KEY (AcademicYearId) REFERENCES AcademicYear(AcademicYearId),
    CONSTRAINT [FKSubjectMappingGrade] FOREIGN KEY (GradeId) REFERENCES Grade(GradeId),
    CONSTRAINT [FKSubjectMappingDivision] FOREIGN KEY (DivisionId) REFERENCES Division(DivisionId), 
    CONSTRAINT [FKSubjectMappingSubjectMaster] FOREIGN KEY (SubjectMasterId) REFERENCES SubjectMaster(SubjectMasterId),
)