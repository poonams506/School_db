CREATE TABLE [dbo].[TransportRoute]
( 
  RouteId BIGINT IDENTITY(1, 1),
  RouteName NVARCHAR(100),
  FirstPickUpTime DATETIME,
  LastPickUpTime DATETIME,
  CoOrdinatorId NVARCHAR(50),
  CoOrdinatorRoleId INT ,
  VehicleId BIGINT,
  IsSharedVehicle BIT DEFAULT(0) NOT NULL,
  SharedRouteId NVARCHAR(50),
  AcademicYearId SMALLINT,
  CreatedBy INT, 
  CreatedDate DATETIME, 
  ModifiedBy INT, 
  ModifiedDate DATETIME, 
  [IsDeleted] BIT DEFAULT(0) NOT NULL,
  CONSTRAINT [PKTransportRoute] PRIMARY KEY (RouteId), 
  CONSTRAINT [FKTransportRouteAcademicYear] FOREIGN KEY (AcademicYearId) REFERENCES AcademicYear(AcademicYearId),
  CONSTRAINT [FKTransportRouteVehicle] FOREIGN KEY (VehicleId) REFERENCES Vehicle(VehicleId)
)
