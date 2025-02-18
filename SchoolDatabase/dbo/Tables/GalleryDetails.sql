CREATE TABLE [dbo].[GalleryDetails]
(
	GalleryDetailsId BIGINT IDENTITY(1, 1),
	GalleryId BIGINT,
	FileName NVARCHAR(100),
    FileType INT,
    CreatedBy INT,
    CreatedDate DATETIME,
    ModifiedBy INT,
    ModifiedDate DATETIME,
    IsDeleted BIT DEFAULT(0) NOT NULL,
    
    CONSTRAINT [PKGalleryDetails] PRIMARY KEY (GalleryDetailsId),
    CONSTRAINT [FKGalleryDetailsGallery] FOREIGN KEY (GalleryId) REFERENCES Gallery(GalleryId)

);
