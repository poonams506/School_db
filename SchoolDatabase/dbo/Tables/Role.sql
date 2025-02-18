CREATE TABLE [dbo].[Role] (
    [RoleId]            INT            IDENTITY (1, 1) NOT NULL,
    [Name]         NVARCHAR (250) NOT NULL,
    [RoleKey] NVARCHAR(250) NULL,
    [IsDeleted]    BIT            DEFAULT ((0)) NOT NULL,
    [CreatedBy] INT,
    [CreatedDate] DATETIME,
    [ModifiedBy] INT,
    [ModifiedDate] DATETIME,
    CONSTRAINT [PKRole] PRIMARY KEY CLUSTERED ([RoleId] ASC)
);

