CREATE TABLE [dbo].[TripDetail]
(
	[TripDetailId] BIGINT IDENTITY(1, 1),
	TripId BIGINT NOT NULL,
	StudentId BIGINT NOT NULL,
	PickUpDateTime DateTime,
	DropOffDateTime DateTime,
	TripRemark NVARCHAR(100),
	IsDeleted BIT DEFAULT((0)) NOT NULL,
	CreatedBy INT, 
    CreatedDate DATETIME, 
    ModifiedBy INT, 
    ModifiedDate DATETIME,
	CONSTRAINT [PKTripDetail] PRIMARY KEY CLUSTERED ([TripDetailId] ASC),
	CONSTRAINT [FKTripDetailTrip] FOREIGN KEY (TripId) REFERENCES Trip(TripId),
	CONSTRAINT [FKTripDetailStudent] FOREIGN KEY (StudentId) REFERENCES Student(StudentId),

)
