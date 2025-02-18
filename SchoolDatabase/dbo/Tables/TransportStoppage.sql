CREATE TABLE [dbo].[TransportStoppage]
(
  StoppageId BIGINT IDENTITY(1, 1),
  StoppageName NVARCHAR(100),
  OrderNo INT,
  AreaId BIGINT,
  PickPrice MONEY,
  DropPrice MONEY,
  PickAndDropPrice MONEY,
  PickUpTime DATETIME,
  DropPickUpTime DATETIME,
  KiloMeter NVARCHAR(50),
  AcademicYearId SMALLINT,
  RouteId BIGINT,
  StopLat NVARCHAR(200),
  StopLng NVARCHAR(200),
  CreatedBy INT, 
  CreatedDate DATETIME, 
  ModifiedBy INT, 
  ModifiedDate DATETIME, 
  [IsDeleted] BIT DEFAULT(0) NOT NULL,
  CONSTRAINT [PKTransportStoppage] PRIMARY KEY (StoppageId), 
  CONSTRAINT [FKTransportStoppageAcademicYear] FOREIGN KEY (AcademicYearId) REFERENCES AcademicYear(AcademicYearId),
  CONSTRAINT [FKTransportStoppageTransportArea] FOREIGN KEY (AreaId) REFERENCES TransportArea(AreaId),
  CONSTRAINT [FKTransportStoppageTransportRoute] FOREIGN KEY (RouteId) REFERENCES TransportRoute(RouteId)

)
