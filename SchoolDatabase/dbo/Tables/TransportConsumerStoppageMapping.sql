CREATE TABLE [dbo].[TransportConsumerStoppageMapping]
(
TransportConsumerStoppageMappingId INT IDENTITY(1,1),
StoppageId BIGINT,
RoleId INT,
ConsumerId BIGINT,
FromDate DATETIME,
ToDate DATETIME,
AcademicYearId SMALLINT,
PickDropId SMALLINT,
PickDropPrice FLOAT,
IsDeleted BIT NOT NULL DEFAULT(0),
CreatedDate DATETIME,
CreatedBy INT,
ModifiedDate DATETIME,
ModifiedBy INT,
CONSTRAINT [PKTransportConsumerStoppageMapping] PRIMARY KEY CLUSTERED (TransportConsumerStoppageMappingId ASC),
CONSTRAINT [FKTransportConsumerStoppageMappingTransportStoppage] FOREIGN KEY (StoppageId) REFERENCES TransportStoppage(StoppageId),
CONSTRAINT [FKTransportConsumerStoppageMappingRole] FOREIGN KEY (RoleId) REFERENCES Role(RoleId)

)
