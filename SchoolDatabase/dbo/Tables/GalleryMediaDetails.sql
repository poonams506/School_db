CREATE TABLE [dbo].[GalleryMediaDetails]
(
	GalleryMediaDetailsId BIGINT IDENTITY(1, 1),
    GalleryId BIGINT,
    ContentUrl NVARCHAR(1000),
    FileType INT,
    CreatedBy INT,
    CreatedDate DATETIME,
    ModifiedBy INT,
    ModifiedDate DATETIME,
    IsDeleted BIT DEFAULT(0) NOT NULL,
    
    CONSTRAINT [PKGalleryMediaDetails] PRIMARY KEY (GalleryMediaDetailsId),
    CONSTRAINT [FKGalleryMediaDetailsGallery] FOREIGN KEY (GalleryId) REFERENCES Gallery(GalleryId) 
)