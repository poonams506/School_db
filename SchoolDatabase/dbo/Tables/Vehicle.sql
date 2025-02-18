CREATE TABLE [dbo].[Vehicle]
(
	 VehicleId BIGINT IDENTITY(1, 1), 
	 VehicleNumber NVARCHAR(20), 
	 TotalSeats INT,
	 RagistrationNumber NVARCHAR(20), 
	 ChassisNumber NVARCHAR(100), 
	 OwnerName NVARCHAR(100), 
	 FinancerName  NVARCHAR(100), 
	 EnginNumber NVARCHAR(100),
	 CompanyName  NVARCHAR(100), 
	 TankCapacity  NVARCHAR(100), 
	 Model NVARCHAR(100), 
	 Type NVARCHAR(100), 
	 FuelType NVARCHAR(100), 
	 CabDriverId BIGINT, 
	 Conductor NVARCHAR(100), 
	 DeviceId  NVARCHAR(100), 
	 ProviderName NVARCHAR(100), 
	 AcademicYearId SMALLINT,
	 CreatedBy INT, 
     CreatedDate DATETIME, 
     ModifiedBy INT, 
     ModifiedDate DATETIME, 
     IsDeleted BIT DEFAULT(0) NOT NULL, 
	 IsActive BIT DEFAULT (0) NOT NULL,
	 CONSTRAINT [PKVehicle] PRIMARY KEY CLUSTERED ([VehicleId] ASC),
     CONSTRAINT [FKVehicleAcademicYear] FOREIGN KEY (AcademicYearId) REFERENCES  AcademicYear(AcademicYearId),
	 CONSTRAINT [FKVehicleCabDriver] FOREIGN KEY (CabDriverId) REFERENCES  CabDriver(CabDriverId)
  );


