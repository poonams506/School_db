CREATE TABLE [dbo].[AdhocFeePayment]
(
 AdhocFeePaymentId BIGINT IDENTITY(1, 1), 
 AcademicYearId SMALLINT,
 GradeId SMALLINT,
 DivisionId SMALLINT,
 StudentId BIGINT,
 InvoiceNumber VARCHAR(100),
 OnlineTransactionId VARCHAR(300),
 OnlineTransactionDateTime DATETIME, 
 OnlinePaymentRequest VARCHAR(1000), 
 OnlinePaymentResponse VARCHAR(1000), 
 PaidToBank NVARCHAR(100), 
 TotalFee MONEY,
 ParticularId SMALLINT,
 PaymentTypeId SMALLINT,
 ChequeNumber NVARCHAR(100), 
 ChequeDate DATETIME, 
 ChequeBank NVARCHAR(100), 
 ChequeAmount MONEY,
 IsChequeClear BIT DEFAULT(0) NOT NULL,
 Remark NVARCHAR(100), 
 CreatedBy INT, 
 CreatedDate DATETIME, 
 ModifiedBy INT, 
 ModifiedDate DATETIME, 
 IsDeleted BIT DEFAULT(0) NOT NULL,
 CONSTRAINT [PKAdhocFeePaymentId] PRIMARY KEY CLUSTERED ([AdhocFeePaymentId] ASC),
 CONSTRAINT [FKAdhocFeePaymentIdAcademicYear] FOREIGN KEY (AcademicYearId) REFERENCES AcademicYear(AcademicYearId),
 CONSTRAINT [FKAdhocFeePaymentIdStudent] FOREIGN KEY (StudentId) REFERENCES Student(StudentId),
 

             
)