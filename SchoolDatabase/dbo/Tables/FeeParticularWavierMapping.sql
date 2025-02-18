CREATE TABLE [dbo].[FeeParticularWavierMapping]
(
	FeeParticularWavierMappingId BIGINT IDENTITY(1,1),
	AcademicYearId SMALLINT,
	GradeId SMALLINT ,
	DivisionId SMALLINT ,
	FeeWavierTypeId BIGINT,
	CreatedBy INT, 
	CreatedDate DATETIME, 
	ModifiedBy INT, 
	ModifiedDate DATETIME, 
	IsDeleted BIT DEFAULT(0) NOT NULL,
	SortBy INT,
	CONSTRAINT [PKFeeParticularWavierMapping] PRIMARY KEY CLUSTERED ([FeeParticularWavierMappingId] ASC),
	CONSTRAINT [FKFeeParticularWavierMappingGrade] FOREIGN KEY ([GradeId]) REFERENCES Grade (GradeId),
	CONSTRAINT [FKFeeParticularWavierMappingDivision] FOREIGN KEY ([DivisionId]) REFERENCES Division (DivisionId),
	CONSTRAINT [FKFeeParticularWavierMappingFeeWavierType] FOREIGN KEY (FeeWavierTypeId) REFERENCES FeeWavierTypes (FeeWavierTypeId)
		
);