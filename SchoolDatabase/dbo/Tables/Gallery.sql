CREATE TABLE [dbo].[Gallery]
(
	GalleryId BIGINT IDENTITY(1, 1),
	AcademicYearId SMALLINT,
	Title NVARCHAR(1000),
    Description NVARCHAR(MAX),
	StartDate DATETIME,
	GalleryToType INT,
	IsPublished BIT DEFAULT (0) NOT NULL,
    IsDeleted BIT DEFAULT(0) NOT NULL,
	CreatedBy INT,
    CreatedDate DATETIME,
    ModifiedBy INT,
    ModifiedDate DATETIME,

    CONSTRAINT [PKGallery] PRIMARY KEY (GalleryId), 
    CONSTRAINT [FKGalleryAcademicYear] FOREIGN KEY (AcademicYearId) REFERENCES AcademicYear(AcademicYearId)
)
