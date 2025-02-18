﻿CREATE TABLE [dbo].[StudentKitFeePayment]
(
 StudentKitFeePaymentId BIGINT IDENTITY(1, 1), 
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
 PaidAmount MONEY,
 PaymentTypeId SMALLINT,
 ChequeNumber NVARCHAR(100), 
 ChequeDate DATETIME, 
 ChequeBank NVARCHAR(100), 
 ChequeAmount MONEY,
 IsChequeClear BIT DEFAULT(0) NOT NULL,
 Remark NVARCHAR(100), 
 SkipDiscount BIT DEFAULT(0) NOT NULL,
 CreatedBy INT, 
 CreatedDate DATETIME, 
 ModifiedBy INT, 
 ModifiedDate DATETIME, 
 IsDeleted BIT DEFAULT(0) NOT NULL,
 CONSTRAINT [PKStudentKitFeePayment] PRIMARY KEY CLUSTERED ([StudentKitFeePaymentId] ASC),
 CONSTRAINT [FKStudentKitFeePaymentAcademicYear] FOREIGN KEY (AcademicYearId) REFERENCES AcademicYear(AcademicYearId),
 CONSTRAINT [FKStudentKitFeePaymentStudent] FOREIGN KEY (StudentId) REFERENCES Student(StudentId)
)