CREATE TABLE [dbo].[Trip]
(
	[TripId] BIGINT IDENTITY(1, 1),
	[RouteId] BIGINT NOT NULL,
	TripStartTime DateTime,
	TripEndTime DateTime ,
	TripType NVARCHAR(10),
	IsDeleted BIT DEFAULT((0)) NOT NULL,
	CreatedBy INT, 
    CreatedDate DATETIME, 
    ModifiedBy INT, 
    ModifiedDate DATETIME,
	CONSTRAINT [PKTrip] PRIMARY KEY CLUSTERED ([TripId] ASC),
	CONSTRAINT [FKTripTransportRoute] FOREIGN KEY (RouteId) REFERENCES TransportRoute(RouteId),

)
