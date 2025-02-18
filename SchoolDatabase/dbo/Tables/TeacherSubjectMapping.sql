CREATE TABLE [dbo].[TeacherSubjectMapping]
(
	 TeacherSubjectMappingId BIGINT IDENTITY(1, 1) NOT NULL,
     AcademicYearId SMALLINT,
	 TeacherId BIGINT, 
	 SubjectMasterId INT,
	 CreatedBy INT,
     CreatedDate DATETIME,
     ModifiedBy INT,
     ModifiedDate DATETIME,
     IsDeleted BIT DEFAULT(0) NOT NULL,
     CONSTRAINT [PKTeacherSubjectMapping] PRIMARY KEY (TeacherSubjectMappingId),
     CONSTRAINT [FKTeacherSubjectMappingAcademicYear] FOREIGN KEY (AcademicYearId) REFERENCES AcademicYear(AcademicYearId),
     CONSTRAINT [FKTeacherSubjectMappingSubjectMaster] FOREIGN KEY (SubjectMasterId) REFERENCES SubjectMaster(SubjectMasterId),
     CONSTRAINT [FKTeacherSubjectMappingTeacher] FOREIGN KEY (TeacherId) REFERENCES Teacher(TeacherId)

)
