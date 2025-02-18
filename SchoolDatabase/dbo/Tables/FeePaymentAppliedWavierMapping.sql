CREATE TABLE [dbo].[FeePaymentAppliedWavierMapping]
(
 FeePaymentAppliedWavierMappingId  BIGINT IDENTITY(1, 1),
 StudentId BIGINT,
 AcademicYearId SMALLINT,
 FeePaymentId BIGINT,
 FeeParticularWavierMappingId BIGINT,
 DiscountedPercent NUMERIC(5,4),
 DiscountedAmount MONEY,
 CreatedBy INT, 
 CreatedDate DATETIME, 
 ModifiedBy INT, 
 ModifiedDate DATETIME, 
 IsDeleted BIT DEFAULT(0) NOT NULL,
 CONSTRAINT [PKFeePaymentAppliedWavierMapping] PRIMARY KEY CLUSTERED ([FeePaymentAppliedWavierMappingId] ASC),
 CONSTRAINT [FKFeePaymentAppliedWavierMappingFeePayment] FOREIGN KEY (FeePaymentId) REFERENCES FeePayment(FeePaymentId),
 CONSTRAINT [FKFeePaymentAppliedWavierMappingFeePatricularWavierMapping] FOREIGN KEY (FeeParticularWavierMappingId ) REFERENCES FeeParticularWavierMapping(FeeParticularWavierMappingId),
 CONSTRAINT [FKFeePaymentAppliedWavierMappingStudent] FOREIGN KEY (StudentId) REFERENCES Student(StudentId) 
  
);


