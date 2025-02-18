CREATE TABLE [dbo].[LeavingCertificateAudits]
(
	LeavingCertificateAuditsId  BIGINT IDENTITY(1,1),
	StudentId BIGINT,
	GradeId SMALLINT ,
	DivisionId SMALLINT,
	StatusId INT DEFAULT(0) NOT NULL,
	Remark NVARCHAR(500),
	Progress NVARCHAR(200),
	Conduct NVARCHAR(200),
	DateOfLeavingTheSchool Date,
	DateSignCurrent Date,
	StdInWhichStudyingAndSinceWhenInWordsAndFigures NVARCHAR(200),
	ReasonOfLeavingSchool NVARCHAR(300),
	SerialNumber INT,
	CreatedBy INT, 
	CreatedDate DATETIME, 
	ModifiedBy INT, 
	ModifiedDate DATETIME, 
	IsDeleted BIT DEFAULT(0) NOT NULL,
	CONSTRAINT [PKLeavingCertificateAudits] PRIMARY KEY CLUSTERED ([LeavingCertificateAuditsId] ASC),
	CONSTRAINT [FKLeavingCertificateAuditsStudent] FOREIGN KEY (StudentId) REFERENCES Student( StudentId),
	CONSTRAINT [FKLeavingCertificateAuditsGrade] FOREIGN KEY (GradeId) REFERENCES Grade(GradeId),
	CONSTRAINT [FKLeavingCertificateAuditsDivision] FOREIGN KEY (DivisionId) REFERENCES Division(DivisionId)	

)
