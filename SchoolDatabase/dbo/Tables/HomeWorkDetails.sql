CREATE TABLE [dbo].[HomeWorkDetails]
(
    HomeWorkDetailsId BIGINT IDENTITY(1, 1),
    HomeWorkId BIGINT,
    FileName NVARCHAR(100),
    FileType INT,
    CreatedBy INT,
    CreatedDate DATETIME,
    ModifiedBy INT,
    ModifiedDate DATETIME,
    IsDeleted BIT DEFAULT(0) NOT NULL,
    
    CONSTRAINT [PKHomeWorkDetails] PRIMARY KEY (HomeWorkDetailsId),
    CONSTRAINT [FKHomeWorkDetailsHomeWork] FOREIGN KEY (HomeWorkId) REFERENCES HomeWork(HomeWorkId) 
);

