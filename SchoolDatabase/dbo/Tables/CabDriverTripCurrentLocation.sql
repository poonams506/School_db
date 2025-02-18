CREATE TABLE dbo.CabDriverTripCurrentLocation(
  
  CabDriverTripCurrentLocationId BIGINT IDENTITY(1, 1),
  TripId [BIGINT],
  Lat  DECIMAL(18,6),
  Long DECIMAL(18,6),
  LastSyncDate DATETIME,
  CONSTRAINT [PKCabDriverTripCurrentLocation] PRIMARY KEY CLUSTERED ([CabDriverTripCurrentLocationId] ASC),
  CONSTRAINT [FKCabDriverTripCurrentLocationTrip] FOREIGN KEY (TripId) REFERENCES Trip(TripId)

);
