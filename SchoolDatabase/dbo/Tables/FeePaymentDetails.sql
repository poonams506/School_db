﻿CREATE TABLE [dbo].[FeePaymentDetails]
(
 FeePaymentDetailId BIGINT IDENTITY(1, 1), 
 FeeParticularId BIGINT,
 StudentId BIGINT,
 AcademicYearId SMALLINT,
 FeePaymentId BIGINT,
 InvoiceNumber VARCHAR(100),
 OtherFeeReason NVARCHAR(500),
 FeeAfterDiscount MONEY,
 PaidAmount MONEY,
 IsChequeClear BIT DEFAULT(0) NOT NULL,
 PaymentTypeId SMALLINT,
 AdditionalDiscInPercentage NUMERIC(5,4),
 AdditionalDiscAmount MONEY,
 CreatedBy INT, 
 CreatedDate DATETIME, 
 ModifiedBy INT, 
 ModifiedDate DATETIME, 
 IsDeleted BIT DEFAULT(0) NOT NULL,
 CONSTRAINT [PKFeePaymentDetails] PRIMARY KEY CLUSTERED ([FeePaymentDetailId] ASC),
 CONSTRAINT [FKFeePaymentDetailsAcademicYear] FOREIGN KEY (AcademicYearId) REFERENCES AcademicYear(AcademicYearId),
 CONSTRAINT [FKFeePaymentDetailsFeePayment] FOREIGN KEY (FeePaymentId ) REFERENCES FeePayment(FeePaymentId ),
 CONSTRAINT [FKFeePaymentDetailsStudent] FOREIGN KEY (StudentId) REFERENCES Student(StudentId)
)