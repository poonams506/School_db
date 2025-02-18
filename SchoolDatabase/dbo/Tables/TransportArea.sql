CREATE TABLE [dbo].[TransportArea]
(
  AreaId BIGINT IDENTITY(1, 1),
  AreaName NVARCHAR(100),
  PickPrice MONEY,
  DropPrice MONEY,
  PickAndDropPrice MONEY,
  Description NVARCHAR(500),
  AcademicYearId SMALLINT,
  CreatedBy INT, 
  CreatedDate DATETIME, 
  ModifiedBy INT, 
  ModifiedDate DATETIME, 
  [IsDeleted] BIT DEFAULT(0) NOT NULL,
  CONSTRAINT [PKTransportArea] PRIMARY KEY (AreaId), 
  CONSTRAINT [FKTransportAreaAcademicYear] FOREIGN KEY (AcademicYearId) REFERENCES AcademicYear(AcademicYearId)
)
