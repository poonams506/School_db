CREATE TABLE [dbo].[CertificateAudits]
(
	CertificateAuditsId  BIGINT IDENTITY(1,1),
	CertificateTemplateId SMALLINT,
	StudentId BIGINT,
	GradeId SMALLINT ,
	DivisionId SMALLINT,
	AcademicYearId SMALLINT,
	IsPublished BIT DEFAULT(0) NOT NULL,
	Remark NVARCHAR(500),
	CreatedBy INT, 
	CreatedDate DATETIME, 
	ModifiedBy INT, 
	ModifiedDate DATETIME, 
	IsDeleted BIT DEFAULT(0) NOT NULL,
	CONSTRAINT [PKCertificateAudits] PRIMARY KEY CLUSTERED ([CertificateAuditsId] ASC),
	CONSTRAINT [FKCertificateAuditsAcademicYear] FOREIGN KEY (AcademicYearId) REFERENCES AcademicYear(AcademicYearId),
	CONSTRAINT [FKCertificateAuditsStudent] FOREIGN KEY (StudentId) REFERENCES Student( StudentId),
	CONSTRAINT [FKCertificateAuditsGrade] FOREIGN KEY (GradeId) REFERENCES Grade(GradeId),
	CONSTRAINT [FKCertificateAuditsDivision] FOREIGN KEY (DivisionId) REFERENCES Division(DivisionId)	

)
