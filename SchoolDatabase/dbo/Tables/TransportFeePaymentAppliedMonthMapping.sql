CREATE TABLE [dbo].[TransportFeePaymentAppliedMonthMapping]
(
 TransportFeePaymentAppliedMonthMappingId  BIGINT IDENTITY(1, 1),
 ConsumerId BIGINT,
 TransportConsumerStoppageMappingId INT,
 RoleId INT,
 AcademicYearId SMALLINT,
 TransportFeePaymentId BIGINT,
 MonthMasterId SMALLINT,
 TransportFeeAdditionalDiscountId BIGINT,
 CreatedBy INT, 
 CreatedDate DATETIME, 
 ModifiedBy INT, 
 ModifiedDate DATETIME, 
 IsDeleted BIT DEFAULT(0) NOT NULL,
 CONSTRAINT [PKTransportFeePaymentAppliedMonthMapping] PRIMARY KEY CLUSTERED ([TransportFeePaymentAppliedMonthMappingId] ASC),
 CONSTRAINT [FKTransportFeePaymentAppliedMonthMappingFeePayment] FOREIGN KEY (TransportFeePaymentId) REFERENCES TransportFeePayment(TransportFeePaymentId),
 CONSTRAINT [FKTransportFeePaymentAppliedMonthMappingMonthMaster] FOREIGN KEY (MonthMasterId) REFERENCES MonthMaster(MonthMasterId),
 CONSTRAINT [FKTransportFeePaymentAppliedMonthMappingTransportFeeAdditionalDiscount] FOREIGN KEY (TransportFeeAdditionalDiscountId) REFERENCES TransportFeeAdditionalDiscount(TransportFeeAdditionalDiscountId),
 CONSTRAINT [FKTransportFeePaymentAppliedMonthMappingRole] FOREIGN KEY (RoleId) REFERENCES Role(RoleId),
 CONSTRAINT [FKTransportFeePaymentAppliedMonthMappingTransportConsumerStoppage] FOREIGN KEY (TransportConsumerStoppageMappingId) REFERENCES TransportConsumerStoppageMapping(TransportConsumerStoppageMappingId)
);


