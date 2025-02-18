CREATE TABLE [dbo].[School] (
    [SchoolId]               INT            IDENTITY (1, 1) NOT NULL,
    [Code]             NVARCHAR (250) NOT NULL,
    [ConnectionString] NVARCHAR (500) NOT NULL,
    [IsDeleted]       BIT            DEFAULT ((0)) NOT NULL,
    [CreatedBy] INT,
    [CreatedDate] DATETIME,
    [ModifiedBy] INT,
    [ModifiedDate] DATETIME,
    CONSTRAINT [PKSchoolId] PRIMARY KEY CLUSTERED ([SchoolId] ASC)
);

